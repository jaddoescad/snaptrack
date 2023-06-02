import { VercelRequest, VercelResponse } from "@vercel/node";
import multiparty from "multiparty";
import { createClient } from "@supabase/supabase-js";
import fs from "fs";
import sharp from "sharp";
import { v4 as uuidv4 } from 'uuid';

const supabase = createClient(
  "https://alsjhtogwmbcfwwpfgam.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsc2podG9nd21iY2Z3d3BmZ2FtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTY4NDg3NDIzNSwiZXhwIjoyMDAwNDUwMjM1fQ.L4ddvKCITNWrFx59O8P5seTrg9Jyg7V5NtK0R8CA2Ug"
);

const MAX_FILE_SIZE = 5 * 1024 * 1024; // Maximum file size 5MB

export default async (req: VercelRequest, res: VercelResponse): Promise<void> => {
  if (req.method === "POST") {
    const form = new multiparty.Form();

    console.log("activating")

    form.parse(req, async function (err, fields, files) {

      if (err) {
        res.status(500).json({ error: err.toString() });
        return;
      }

      const file = files.file[0]; // Assuming 'file' is the key of the uploaded file
      const { path: filePath } = file;
      
      const fileBuffer = await fs.promises.readFile(filePath);

      if (fileBuffer.byteLength > MAX_FILE_SIZE) {
        res.status(400).json({ error: "File size exceeds the maximum limit of 5MB" });
        return;
      }

      const resizedImageBuffer = await sharp(fileBuffer)
        .resize(320, 320, {
          fit: 'contain'
        }) // Modify these dimensions as per your requirements
        .jpeg() // Modify this as per your requirements
        .toBuffer();

      const randomUid = uuidv4();  // Generates a unique id
      const resizedImageSize = resizedImageBuffer.byteLength;

      // Upload original image
      let { data, error } = await supabase
        .storage
        .from('test')
        .upload(`ImageDocuments/${randomUid}.png`, fileBuffer);

      
      if (error) {
        res.status(400).json({ error: error.message });
        return;
      }

      // Upload resized image
      let { data: resizedData, error: resizedError } = await supabase
        .storage
        .from('test')
        .upload(`ImageDocuments/${randomUid}_resized_${resizedImageSize}.png`, resizedImageBuffer);

      if (resizedError) {
        res.status(400).json({ error: resizedError.message });
        return;
      }

      res.json({ message: "File uploaded and resized successfully" });
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
