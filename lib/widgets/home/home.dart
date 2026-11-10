import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isConnected = false;

  String get _formattedTime {
    final hours = (_secondsElapsed ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_secondsElapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;

      if(_isConnected){
        _secondsElapsed = 0;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
          });
        });
      }else{
        _timer?.cancel();
        }
    });
  }
  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      children: [
      Container(
      height: 195,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.vulcanCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mirageBorder80),
      ),
      child: Center(
        child: GestureDetector(
        onTap: _toggleConnection,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.vulcanCard,
            shape: BoxShape.circle,
            border: Border.all(
              color:AppColors.turquoiseBlue,
              width: 2.0,
            ),
            boxShadow: _isConnected?[
              BoxShadow(color: AppColors.turquoiseBlue.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 0.5,
              ),
            ]
                :[]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 32,
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.power_settings_new,
                      color:AppColors.turquoiseBlue,
                      size: 28,
                      shadows: _isConnected?[
                        const Shadow(
                          color: AppColors.turquoiseBlue,
                          blurRadius: 8,
                        ),
                      ]
                        :[],
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
              child : Text(
                _isConnected ? "Connected" : "Connect",
                key: ValueKey<bool>(_isConnected),
                style: TextStyle(
                  color:AppColors.blackPearl,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: _isConnected?[
                    const Shadow(
                      color: AppColors.turquoiseBlue,
                      blurRadius: 5,
                    ),
                  ]
                      :[],
                ),
              ),
              ),
              if(_isConnected)
                AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _formattedTime,
                  style: const TextStyle(
                    color: AppColors.turquoiseBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: AppColors.vulcanCard,
                        blurRadius: 5,
                      ),
                    ]
                  )
                )
                )],
          ),
        ),
      ),
    ),)],
    );
  }
}
