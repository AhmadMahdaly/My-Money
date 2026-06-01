import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/models/app_currency.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/services/app_settings_service.dart';
import 'package:opration/core/shared_widgets/currency_picker_field.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/auth/presentation/cubit/login_cubit.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _nameController = TextEditingController();
  late String _selectedCurrencyCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = AppSettingsService.savedCurrencyCode;
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.username;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCustomSnackBar(message: 'متنساش تسجل اسمك', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<AuthCubit>().updateUsername(name);
      await AppSettingsService.saveCurrencyCode(_selectedCurrencyCode);
      if (!mounted) return;
      showCustomSnackBar(message: 'تم حفظ الإعدادات');
      context.pop();
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(message: 'فشل حفظ الإعدادات', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = currencyByCode(_selectedCurrencyCode);

    return Scaffold(
      appBar: PageHeader(
        isLeading: true,
        height: 16.h,
        title: 'إعدادات التطبيق',
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Text(
            'الاسم',
            style: AppTextStyle.style14W600.copyWith(
              color: AppColors.primaryTextColor,
            ),
          ),
          8.verticalSpace,
          CustomPrimaryTextfield(
            controller: _nameController,
            text: 'اسمك كما يظهر في التطبيق',
            textInputAction: TextInputAction.next,
          ),
          24.verticalSpace,
          CurrencyPickerField(
            selectedCode: _selectedCurrencyCode,
            onChanged: (code) => setState(() => _selectedCurrencyCode = code),
          ),
          8.verticalSpace,
          Text(
            'العملة الحالية: ${selectedCurrency.nameAr}',
            style: AppTextStyle.style12W400.copyWith(
              color: AppColors.secondaryTextColor,
            ),
          ),
          32.verticalSpace,
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else
            CustomPrimaryButton(
              width: double.infinity,
              text: 'حفظ الإعدادات',
              onPressed: _saveSettings,
            ),
        ],
      ),
    );
  }
}
