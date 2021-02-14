import 'package:flutter/material.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ImageUploadPage> {
  String imageURL;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        children: <Widget>[
          (imageURL != null)
              ? Image.network(imageURL)
              : Placeholder(
                  fallbackHeight: 200.0,
                  fallbackWidth: double.infinity,
                ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text('Upload Image'),
            color: Colors.lightBlue,
            onPressed: () {},
          )
        ],
      ),
    );
  }

  uploadImage() {
    //Check Permissions

    //Select Image

    //Upload to Firebase
  }
}
