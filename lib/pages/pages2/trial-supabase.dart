import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class HomePageSupabase extends StatefulWidget {
  const HomePageSupabase({super.key});

  @override
  State<HomePageSupabase> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageSupabase> {
  final _future = Supabase.instance.client.from('instruments').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final instruments = snapshot.data!;
          return ListView.builder(
            itemCount: instruments.length,
            itemBuilder: ((context, index) {
              final instrument = instruments[index];
              return ListTile(
                  title: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instrument['name']),
                      Text(instrument['price'].toString()),
                    ],
                  )
                ],
              ));
            }),
          );
        },
      ),
    );
  }
}
