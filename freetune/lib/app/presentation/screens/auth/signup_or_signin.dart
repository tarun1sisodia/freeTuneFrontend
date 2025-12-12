import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../widgets/common/basic_app_button.dart';
import '../../../core/configs/assets/app_images.dart';
import '../../../routes/app_routes.dart';

class SignupOrSigninScreen extends StatelessWidget {
  const SignupOrSigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Enforce dark theme
      body: Stack(
        children: [
          const BasicAppBar(hideBack: true),
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(AppImages.logo,
                height: 100,
                color:
                    Colors.white.withOpacity(0.1)), // Placeholder for unionTop
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(AppImages.logo,
                height: 100,
                color: Colors.white
                    .withOpacity(0.1)), // Placeholder for unionBottom
          ),
          // Align(
          //   alignment: Alignment.bottomLeft,
          //   child: Image.asset(AppImages.chooseAuthBG), // Placeholder or remove if no asset
          // ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.logo, height: 60),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Enjoy Listening To Music',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 29,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'FreeTune is a proprietary audio streaming and media services provider',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      fontSize: 19,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          onPressed: () {
                            Get.toNamed(Routes.REGISTER);
                          },
                          title: "Register",
                          textSize: 20,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        width: 21,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.LOGIN);
                          },
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered) ||
                                  states.contains(WidgetState.pressed)) {
                                return Colors.white.withOpacity(0.1);
                              }
                              return null; // Defer to the widget's default.
                            }),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered) ||
                                  states.contains(WidgetState.pressed)) {
                                return Colors
                                    .white; // Keep white on hover/press
                              }
                              return Colors.white; // Default text color
                            }),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
