import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildTextField(TextEditingController controller, String label, String? validationMessage,{bool required = true,TextInputType inputType = TextInputType.text,}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return validationMessage ?? 'This field is required';
        }
        return null;
      },
    ),
  );
}
Widget buildDatePickerTextField(
    BuildContext context, // Add BuildContext as a parameter
    TextEditingController controller,
    String label,
    String? validationMessage, {
      bool required = true,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      readOnly: true, // Prevents keyboard from appearing
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return validationMessage ?? 'This field is required';
        }
        return null;
      },
      onTap: () async {
        // Show date picker when tapped
        DateTime? pickedDate = await showDatePicker(
          context: context, // Use the context from the parameter
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.yellow, // header background color
                  onPrimary: Colors.black, // header text color
                  surface: Colors.blueGrey, // body color
                  onSurface: Colors.white, // body text color
                ),
                dialogBackgroundColor: Colors.black87,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          // Format date and set to controller
          String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          controller.text = formattedDate;
        }
      },
    ),
  );
}
