import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pull_to_refresh/pull_to_refresh.dart';


const request = "https://api.hgbrasil.com/finance?key=36f583bd";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
    
  double dolar;
  double euro;

  void _realChanged(String text){
    if (text.isEmpty) {
      return _resetValues();
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if (text.isEmpty) {
      return _resetValues();
    }
    double dolar = double.parse(text);
    realController.text = (dolar*this.dolar).toStringAsFixed(2);
    euroController.text = (dolar*this.dolar/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if (text.isEmpty) {
      return _resetValues();
    }
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = (euro*this.euro / dolar).toStringAsFixed(2);
  }
  void _resetValues(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = ""; 
  }

  Future<Map> getData() async {
    http.Response response = await http.get(request);
    return json.decode(response.body);
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async{
    _resetValues();
    await Future.delayed(Duration(milliseconds: 500));
    _refreshController.refreshCompleted();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFe7e6e1),
      appBar: AppBar(
        title: Text ("Conversor",
          style: TextStyle(
              color: Color(0xFFEAE8FE),
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
          ),
        ),
        backgroundColor: Color(0xFF1F1F98),
        centerTitle: true,
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropMaterialHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child:
        FutureBuilder <Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return showLoadingMessage();
            default:
              return contentLoaded(snapshot);
          }

        }) ,
      ),
    );
  }

  Widget contentLoaded(AsyncSnapshot<Map> snapshot) {
    if(snapshot.hasError){
      return showErrorMessage();
    }
    dolar = snapshot.data["results"]["currencies"] ["USD"]["buy"];
    euro = snapshot.data["results"]["currencies"] ["EUR"]["buy"];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(Icons.monetization_on, size: 70, color: Color(0xFF01F1F98)),
          SizedBox(height: 30.0,),
          
          moneyField("Real R\$", realController, _realChanged ),
          SizedBox(height: 25.0),
          moneyField("Dólares US\$", dolarController, _dolarChanged),
          SizedBox(height: 25.0),
          moneyField("Euros €", euroController, _euroChanged)
        ],
       ),
      );
  }

  Container moneyField(String label, TextEditingController controller, Function converter) {
    return Container(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFFFF70A2),
          contentPadding:
          const EdgeInsets.only(left: 25.0, bottom: 08.0, top: 17.0),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(35),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFF70A2)),
            borderRadius: BorderRadius.circular(25.7),
          ),
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF1F1F98)),
        ),
        style: TextStyle(
          color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold,
        ),
        onChanged: converter,
        keyboardType: TextInputType.number,
      ),
    );
  }
  Center showErrorMessage() {
    return Center(
      child: Text ("Erro ao carregar dados! :( ",
    style: TextStyle(
        color: Colors.yellow,
        fontSize: 25.0),
    textAlign: TextAlign.center));
  }

  Center showLoadingMessage() {
    return Center(
      child: Text ("Carregando Dados ...",
        style: TextStyle(
          color: Color(0xFF1F1F98),
          fontSize: 30.0,
          fontWeight: FontWeight.bold),
        textAlign: TextAlign.center)
    );
  }

  
}
        
