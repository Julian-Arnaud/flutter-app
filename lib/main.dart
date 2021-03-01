import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Article details = new Article('title', 'taille', 'prix', 'marque', '');
List<Article> theBasket = [new Article('ART1', 'XS', '10€', 'Nike', ''), new Article('ART2', 'XL', '12€', 'Adidas', '')];
Profil user;

void main() {
  runApp(MyApp());
}

class DetailArticle extends StatefulWidget{
  DetailArticle({Key key}): super(key: key);
  @override
  _DetailArticleState createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(details.getTitle())
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(details.toString()),
              ElevatedButton(
                child: Text('Ajouter au Panier'),
                onPressed: (){
                  DocumentReference dr = Firestore.instance.collection('basket').document(user.login);
                  dr.setData(details.toMap(), merge: false);
                },
              )
            ]
        ),
      )
    );
  }
}

class LePanier extends StatefulWidget{
  LePanier({Key key}) : super(key: key);

  _LePanierState createState() => _LePanierState();
}

class _LePanierState extends State<LePanier>{
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Le panier'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('basket').document(user.login).snapshots(),
        builder: (BuildContext  context,AsyncSnapshot snapshot){
          if(!snapshot.hasData) return LinearProgressIndicator();
          return new ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext ctx, int index){
              DocumentSnapshot ds = snapshot.data;
              details.prix = ds['price'];
              return new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(ds['title']+'\n'+ds['size']+'\n'+ds['price']+'\n'+ds['brand']+'\n'+ds['image']),
                    ElevatedButton(
                      child: Text('Enlever du panier'),
                      onPressed: (){
                        DocumentReference dr = Firestore.instance.collection('basket').document(user.login);
                        details.title = '';
                        details.prix = '';
                        details.taille = '';
                        details.image = '';
                        details.marque = '';
                        dr.setData(details.toMap());
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Text('Total: ' + details.prix),
      ),
    );
  }
}

class LeProfil extends StatefulWidget{
  LeProfil({Key key}) : super(key: key);

  _LeProfilState createState() => _LeProfilState();
}

class _LeProfilState extends State<LeProfil>{
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  TextEditingController _postalController = new TextEditingController();
  TextEditingController _addressController = new TextEditingController();
  DateTime _birthday = DateTime.now();

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Le profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              readOnly: true,
              initialValue: user.login,
              decoration: InputDecoration(
                labelText: 'Login'
              ),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password'
              ),
            ),
            InputDatePickerFormField(
              initialDate: user.birth,
              firstDate: DateTime(1900,1,1),
              lastDate: DateTime.now()
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                  labelText: 'Adresse',
                hintText: user.address
              ),
            ),
            TextFormField(
              controller: _postalController,
              decoration: InputDecoration(
                  labelText: 'Code postal',
                hintText: user.postal
              ),
            ),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                  labelText: 'Ville',
                hintText: user.city
              ),
            ),
            ElevatedButton(
              child: Text('Valider'),
              onPressed: (){
                //mettre à jour les données (lol quand la base sera up)
                user.password = _passwordController.text == '' ? user.password : _passwordController.text;
                user.city = _cityController.text == '' ? user.city : _cityController.text;
                user.postal = _postalController.text == '' ? user.postal : _postalController.text;
                user.address = _addressController.text == '' ? user.address : _addressController.text;
                user.password = user.password;
                user.birth = user.birth;
                DocumentReference dr = Firestore.instance.collection('users').document(user.login);
                dr.setData(user.toMap(), merge: true);
              },
            ),
            ElevatedButton(
              child: Text('Se déconnecter'),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'MIAGED')));
              },
            )
            ],//on place un form ici
    )));
  }
}

class LesArticles extends StatefulWidget{
  LesArticles({Key key, this.listArticles}) : super(key: key);
  final List<String> listArticles;
  @override
  _LesArticlesState createState() => _LesArticlesState();
}

class _LesArticlesState extends State<LesArticles> {
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Icon(Icons.attach_money_outlined),
              onPressed: (){

              },
            ),
            ElevatedButton(
              child: Icon(Icons.shopping_cart),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LePanier()));
              },
            ),
            ElevatedButton(
              child: Icon(Icons.account_circle_outlined),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeProfil()));
              },
            )
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('cloths').snapshots(),
        builder: (BuildContext  context,AsyncSnapshot snapshot){
          if(!snapshot.hasData) return LinearProgressIndicator();
          return new ListView.builder(
            itemCount: snapshot.data.documents.length,
            padding: const EdgeInsets.only(top: 10.0),
            itemBuilder: (context, index){
              DocumentSnapshot ds = snapshot.data.documents[index];
              return new ElevatedButton(
                onPressed: (){
                  details = new Article(ds['title'], ds['size'], ds['price'], ds['brand'], ds['image']);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailArticle()));
                },
                child:
                  Text(ds['title']+'\n'+ds['price']+'\n'+ds['size']+'\n'+ds['brand']+'\n'+ds['image']),
              );
            },
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIAGED',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'MIAGED'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController loginController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  _checkCredentials(BuildContext ctx){

    Firestore.instance.collection('users').document(loginController.text).get().then((ds) => {
      user = new Profil(ds['login'], ds['password'], ds['birthday'], ds['address'], ds['postal'], ds['city'])
    }).then((dat) => {
      if(loginController.text == user.login && passwordController.text == user.password) Navigator.push(ctx, MaterialPageRoute(builder: (ctx) => LesArticles()))
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            TextFormField(
              controller: loginController,
          decoration: InputDecoration(
              labelText: 'Login'
          )
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password'
              ),
            ),
            ElevatedButton(
              onPressed: (){
                _checkCredentials(context);
              }
              ,child: Text('Se connecter'),
            )
          ],
        ),
      ),
    );
  }
}

class Article{
  String title;
  String taille;
  String prix;
  String marque;
  String image;

  Article(this.title, this.taille, this.prix, this.marque, this.image);
  String getTitle(){return this.title;}
  @override
  String toString() {
    return 'Article{title: $title, taille: $taille, prix: $prix, image: $image}';
  }

  Map<String, dynamic> toMap(){
    return {
      "title": title,
      "size": taille,
      "price": prix,
      "brand": marque,
      "image": image
    };
  }
}

class Profil{
  String login;
  String password;
  DateTime birth;
  String address;
  String postal;
  String city;

  Profil(this.login, this.password, this.birth, this.address, this.postal,
      this.city);

  Map<String, dynamic> toMap() {
    return {
      "login": login,
      "password": password,
      "birth": birth,
      "address": address,
      "postal": postal,
      "city": city
    };
  }
}