import 'package:flutter/material.dart';
import 'package:social/extensions/theme_extension.dart';
import 'package:social/helpers/app_color.dart';
import 'package:social/views/general/main_layout_view.dart';
import 'package:social/widgets/custom_elevated_button.dart';
import 'package:social/widgets/custom_text_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      showNavbar: false,
      title: Text(
        "Profil Düzenle",
        style: TextStyle(
          color: context.themeValue(
            light: AppColors.lightText,
            dark: AppColors.darkText,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Handle avatar change
                      },
                      child: Text(
                        "Profil fotoğrafını değiştir",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildTextField(controller: _nameController, hint: "Ad"),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _usernameController,
                hint: "Kullanıcı adı",
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Biyografi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: Icon(Icons.lock, color: Colors.grey[700]),
                title: Text("Özel Hesap"),
                subtitle: Text("Hesabınızı gizli yapın"),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomElevatedButton(
                width: double.infinity,
                buttonText: "Kaydet",
                onPressed: () {
                  // Handle save
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return CustomTextField(
      hintText: hint,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
