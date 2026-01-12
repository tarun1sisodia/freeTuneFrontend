import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../widgets/common/basic_app_button.dart';
import '../../../core/configs/assets/app_images.dart';
import 'app_colors.dart';
import '../../widgets/common/sized.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: BasicAppBar(
        hideBack: true,
        title: Image.asset(
          AppImages.logo,
          height: TSizes.iconXl,
          width: TSizes.iconXl,
        ),
      ),
      bottomNavigationBar: _registerText(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace,
          vertical: TSizes.appBarHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _signinText(),
            SizedBox(height: TSizes.spaceBtwSections),
            _supportText(),
            SizedBox(height: TSizes.spaceBtwSections),
            _usernameOrEmailField(context, emailController),
            SizedBox(height: TSizes.spaceBtwInputFields),
            _passwordField(context, passwordController),
            SizedBox(height: TSizes.spaceBtwInputFields),
            _recoveryPasswordText(),
            SizedBox(height: TSizes.spaceBtwInputFields),
            Obx(() => BasicAppButton(
                  title:
                      controller.isLoading.value ? 'Signin In...' : 'Sign in',
                  onPressed: controller.isLoading.value
                      ? () {}
                      : () async {
                          final success = await controller.login(
                            emailController.text.trim(),
                            passwordController.text,
                          );
                          if (success) {
                            Get.offAllNamed(Routes.MAIN);
                          }
                        },
                  textSize: TSizes.fontSizeLg,
                  weight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Widget _signinText() {
    return Text(
      'Sign In',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: TSizes.fontSizeXxl,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _supportText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "If You Need Any Support ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: TSizes.fontSizeMd,
            color: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Click here",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: TSizes.fontSizeMd,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _usernameOrEmailField(
      BuildContext context, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Enter Username Or Email",
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius:
                BorderRadius.all(Radius.circular(TSizes.inputFieldRadius))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        contentPadding: EdgeInsets.all(TSizes.md),
      ),
    );
  }

  Widget _passwordField(
      BuildContext context, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius:
                BorderRadius.all(Radius.circular(TSizes.inputFieldRadius))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        contentPadding: EdgeInsets.all(TSizes.md),
      ),
    );
  }

  Widget _recoveryPasswordText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Get.toNamed(Routes.FORGOT_PASSWORD);
          },
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: TSizes.fontSizeMd,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _registerText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: TSizes.appBarHeight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Not A Member ? ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: TSizes.fontSizeMd,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.offNamed(Routes.REGISTER);
            },
            child: Text(
              "Register Now",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: TSizes.fontSizeMd,
                color: AppColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
