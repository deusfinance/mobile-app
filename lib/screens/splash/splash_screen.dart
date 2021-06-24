import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../statics/my_colors.dart';
import 'cubit/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  static const route = "/splash";

  static Future<bool?> init(BuildContext context) async {
    debugPrint("Initializing data...");
    final bool success = await context.read<SplashCubit>().initializeData();
    debugPrint("Call finished.");
    if(!success) return null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(gradient: MyColors.splashGradient),
              child: BlocBuilder<SplashCubit, SplashState>(builder: (context, state) {
                if (state is SplashError)
                  return Center(
                      child: GestureDetector(onTap: () async => await init(context) , child: Icon(Icons.refresh, color: MyColors.White)));
                else
                  return Center(child: SvgPicture.asset("assets/images/deus.svg"));
              })),
//          SvgPicture.asset("assets/images/splash_bg.svg"),
        ],
      ),
    );
  }
}
