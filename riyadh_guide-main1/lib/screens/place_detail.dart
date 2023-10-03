import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';

// ignore: camel_case_types
class placeDetails extends StatelessWidget{
  const placeDetails({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left:0,
            right:0,
            
           
            child: Container(
                width: double.maxFinite,
                height: 350, //change to screen hight 
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "lib/icons/Restraunt.jpg"
                    )
                  )
                ),
            )),
            Positioned(
              top:45,
               left:20,
               right:20,
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                children: [
                  AppIcon(icon: Icons.arrow_back_ios),
                  AppIcon(icon: Icons.favorite)
                ],
 
            )),
            Positioned(
              left:0,
              right:0,
              bottom:0,
              top:330, //make it the image diminsion
              child: Container(
                padding: const EdgeInsets.only(left: 9, right: 9, top: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft:  Radius.circular(20)
                  ),
                  color:Colors.white
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(
  "بيتزاريا دا ميمو",
  style: TextStyle(
    fontSize: 24, // Adjust the font size as needed
    fontWeight: FontWeight.bold, // You can also apply other styles
  ),
                   ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Wrap(
                          children: List.generate(5, (index) => Icon(Icons.star,color:Colors.yellow,size:15)),
                        ),
                        SizedBox(width:10,),
                        Text( "4.5"),
                        SizedBox(width:10,),
                        Text("230"),
                        SizedBox(width:10,),
                        Text("تعليق")
                      ],
                      ),
                      SizedBox(height:20,),
                      Row(
                        children: [
                          IconAndTextWidget(icon: Icons.circle_sharp, text: "مطعم", iconColor: Colors.purple),
                           SizedBox(width: 20,),
                          IconAndTextWidget(icon: Icons.location_on, text: "1.7كم", iconColor: Colors.blueAccent),
                           SizedBox(width: 20,),
                          IconAndTextWidget(icon: Icons.access_time_rounded, text: "9:00 ص - 12:00 م  ", iconColor: Colors.pinkAccent),
                         
                        ],
                        ),
                     Text(
  "الوصف",
  style: TextStyle(
    fontSize: 24, // Adjust the font size as needed
    fontWeight: FontWeight.bold, // You can also apply other styles
  )),
  Text("في قلب مدينة الرياض، تجد بيتزاريا دا ميمو، المطعم الإيطالي الذي يعدّ افضل مطعم ايطالي في الرياض. يتميز هذا المطعم بجودة طعامه وخدمته الممتازة، حيث يقدم تجربة فريدة لمحبي المطبخ الإيطالي")
                  ],
                  )
                

            ))
        ],
      )
    );
  }
}