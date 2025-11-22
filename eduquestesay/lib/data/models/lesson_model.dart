

import 'package:eduquestesay/data/models/course_model.dart';
import 'package:flutter/material.dart';

class Lesson{
  
    final String id;
    final String title ;
    final String content;
    final  String videoUrl;
    final  String pdfFile;
  

    Lesson(
      {
    required String this.id ,
    required String this.title ,
    required String this.content,
    required  String this.videoUrl,
    required String this.pdfFile    
    });




 Map<String,dynamic> toJson(){
  
  return {
   'id' : id,
   'title' : title,
   'content' : content,
   'videoUrl' : videoUrl,
   'pdfFile': pdfFile

  };

 }


factory  Lesson.fromJson(Map<String , dynamic > json ){
   
   return Lesson(
    id: json['id'].toString(),
    title: json['title'].toString(), 
    content: json['content'].toString(),
    videoUrl: json['videoUrl'].toString(),
    pdfFile: json['pdfFile'].toString()
    );


}




}