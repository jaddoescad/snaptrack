import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/image_grid_page.dart';

class BinsPage extends StatelessWidget {
  BinsPage({Key? key}) : super(key: key);

  // Mock data
  final List<Bin> bins = [
    Bin(number: 1, title: 'Receipts'),
    Bin(number: 2, title: 'Invoices'),
    Bin(number: 3, title: 'Bills'),
    Bin(number: 4, title: 'Very Very Very Very Long Title'),
    // Add more bins if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bins'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement your functionality for the '+' button
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bins.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bins[index].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(bins[index].number.toString()),
            trailing: Icon(Icons.add_photo_alternate),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ItemDetailPage(bin: bins[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
