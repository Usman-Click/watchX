import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
final String url = 'https://api.themoviedb.org/3/trending/movie/day?language=en-US';
final String imgBaseUrl = 'https://image.tmdb.org/t/p/w500';
late Future<Map<String, dynamic>> trendingMovies;

final List<Map<String, dynamic>> filters = [
  {"name": "Popular", "isSelected": false},
  {"name": "Trending", "isSelected": false},
  {"name": "Recommended", "isSelected": false},
  {"name": "New", "isSelected": false},
  {"name": "Old", "isSelected": false},
  {"name": "More", "isSelected": false},
];

@override
  void initState() {
    super.initState();
    try {
          trendingMovies = getTrending();
    } catch (e) {
      print(e);
    }
  }


Future<Map<String, dynamic>> getTrending() async {

  final Map<String, String> headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNjVjMWNlMWJjOTE2YTVmYzgyODEwYWM3NTllMjljZSIsInN1YiI6IjY2NGE2YzIxN2E0ZmJhOTBlZjc5NTg4YyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._fI7hQFdREpxGeGcA5JqPNNc_b1a31R3C6PLoyEHRdY"
    };


  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    try {
         return jsonDecode(response.body);
    } catch (e) {
      throw("Error reading data: $e" );
    }
  }else {
      throw("Invalid Request" );
  }
}



  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Home"),
            actions: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
              const SizedBox(width: 10,),

              IconButton(
                onPressed: (){},
                icon: ClipOval(
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w300/j3Z3XktmWB1VhsS8iXNcrR86PXi.jpg',
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10,),
            ],
        ),

        body:  Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(int i=0; i < filters.length; i++)
                       Padding(
                         padding: const EdgeInsets.all(5.0),
                         child: FilterChip(
                          label: Text(filters[i]["name"]),
                          labelStyle: TextStyle(
                            color: i==0 ? Colors.white : null,
                          ),
                          selectedColor: i==0 ? Colors.red : null,
                          selected: i == 0 ? true : false,
                          showCheckmark: false,
                          onSelected: (e) {
                            
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                         ),
                       ),
                     
                  ],
                ),
              ),

              // Trending movies
              const SizedBox(height: 20,),
              FutureBuilder(future: trendingMovies, builder: (context, snapshot){
                if (snapshot.hasError) {
                  return const Center(child: Text("Unable to load movies, try again letter"));
                }
          
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
          
                final Map<String, dynamic> data = snapshot.data!;
                final img = imgBaseUrl + data["results"][0]["backdrop_path"]; 
                print(data.toString());
          
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // main img
                    Container(
                      decoration: const BoxDecoration(borderRadius:  BorderRadius.all(Radius.circular(20))), 
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(img, width: double.infinity, fit: BoxFit.cover, ),
                    ),

                    // this week
                    const SizedBox(height: 20,),
                    const Text("this week", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),

                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 15,
                        itemBuilder: (context, index){
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              children: [Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                  width: 100,
                                  child: Column(children: [
                                      Image.network(imgBaseUrl + data["results"][index]["backdrop_path"], width: 100, height: 120, fit: BoxFit.cover,),
                                      const SizedBox(height: 5,),
                                      Text(data["results"][index]["original_title"].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,),
                                  ],),
                                ),
                              )]
                          );
                      
                        },),
                    )
          
                  ]
          
                );
               
              }),
          
            ],
          )
        ),
      ),);
  }
}