import { VercelRequest, VercelResponse } from "@vercel/node";
import multiparty from "multiparty";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import fs, { promises as fsPromises } from "fs";
import sharp from "sharp";
import { v4 as uuidv4 } from "uuid";

const SUPABASE_URL: string = "https://alsjhtogwmbcfwwpfgam.supabase.co";
const SUPABASE_SECRET =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsc2podG9nd21iY2Z3d3BmZ2FtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg3NDIzNSwiZXhwIjoyMDAwNDUwMjM1fQ.L4ddvKCITNWrFx59O8P5seTrg9Jyg7V5NtK0R8CA2Ug";
const MAX_FILE_SIZE: number = 5 * 1024 * 1024; // Maximum file size 5MB
const IMAGE_WIDTH: number = 320;
const IMAGE_HEIGHT: number = 320;
const STORAGE_BUCKET: string = "ImageDocuments";
const TABLE_NAME: string = "bin_images";
const POST_METHOD: string = "POST";

export default async (
  req: VercelRequest,
  res: VercelResponse
): Promise<void> => {
  const supabase: SupabaseClient = createClient(SUPABASE_URL, SUPABASE_SECRET, {
    global: {
      headers: { Authorization: req.headers["authorization"] || "" },
    },
  });

  if (req.method === POST_METHOD) {
    const form = new multiparty.Form();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    form.parse(req, async function (err, fields, files) {
      if (err) {
        res.status(500).json({ error: err.toString() });
        return;
      }

      const file = files.file[0];
      const filePath: string = file.path;
      const fileBuffer: Buffer = await fsPromises.readFile(filePath);

      if (fileBuffer.byteLength > MAX_FILE_SIZE) {
        res
          .status(400)
          .json({ error: "File size exceeds the maximum limit of 5MB" });
        return;
      }

      const binId: string = fields.binId[0];
      const originalImageBuffer: Buffer = await sharp(fileBuffer)
        .rotate()
        .png()
        .toBuffer();

      const resizedImageBuffer: Buffer = await sharp(fileBuffer)
        .rotate()
        .resize(IMAGE_HEIGHT, IMAGE_WIDTH, {
          fit: "cover",
        })
        .png()
        .toBuffer();

      const randomUid: string = uuidv4();

      // Upload original image
      let { data, error } = await supabase.storage
        .from(STORAGE_BUCKET)
        .upload(`${user.id}/${binId}/${randomUid}.png`, originalImageBuffer);

      if (error) {
        console.log("error", error);
        res.status(400).json({ error: error.message });
        return;
      }

      // Upload resized image
      let { data: resizedData, error: resizedError } = await supabase.storage
        .from(STORAGE_BUCKET)
        .upload(
          `${user.id}/${binId}/${randomUid}_${IMAGE_WIDTH}x${IMAGE_HEIGHT}.png`,
          resizedImageBuffer
        );

      if (resizedError) {
        res.status(400).json({ error: resizedError.message });
        return;
      }

      if (!data?.path || !resizedData?.path) {
        res.status(400).json({ error: "Something went wrong" });
        return;
      }

      // Storing the paths into the database
      let { data: dbData, error: dbError } = await supabase
        .from(TABLE_NAME)
        .insert([
          {
            img_url: data?.path,
            bin_id: binId,
            thumbnail_url: resizedData?.path,
          },
        ]).select('*');

      if (dbError) {
        console.log("dbError", dbError);
        res.status(400).json({ error: dbError.message });
        return;
      }

      res.status(200).json({id: dbData?.[0]["id"], original: data.path, resized: resizedData.path });
    });
  } else {
    console.log(
      "Method not allowed. Only POST requests are accepted at this endpoint.",
      req.method
    );
    res.status(405).json({ error: "Method not allowed" });
  }
};

export const config = {
  api: {
    bodyParser: false,
  },
};
