import 'package:flutter/material.dart';

class PlanTitleField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isEditMode;
  final String? editPlanName;

  const PlanTitleField({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.isEditMode,
    this.editPlanName,
  }) : super(key: key);

  @override
  PlanTitleFieldState createState() => PlanTitleFieldState();
}

class PlanTitleFieldState extends State<PlanTitleField> {
  late TextEditingController _controller;
  String _currentValue = "";

  @override
  void initState() {
    super.initState();
    
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue);
    
    print("🔧 PlanTitleField initialized with: '${widget.initialValue}'");
    
    // ✅ WYWOŁAJ CALLBACK PRZEZ PostFrameCallback
    if (widget.initialValue.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(widget.initialValue);
        }
      });
    }
    
    _controller.addListener(_onTextChanged);
    
    // if (widget.isEditMode && widget.editPlanName != null && widget.editPlanName!.isNotEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       _setInitialEditValue(widget.editPlanName!);
    //     }
    //   });
    // }
  }

  @override
  void didUpdateWidget(PlanTitleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialValue != oldWidget.initialValue) {
      _setControllerValue(widget.initialValue);
    }
    
    // if (widget.isEditMode && 
    //     widget.editPlanName != oldWidget.editPlanName && 
    //     widget.editPlanName != null && 
    //     widget.editPlanName!.isNotEmpty) {
    //   _setInitialEditValue(widget.editPlanName!);
    // }
  }

   void _setInitialEditValue(String planName) {
    print("✏️ Setting initial edit value: '$planName'");
    print("  Current controller text: '${_controller.text}'");
    print("  Current _currentValue: '$_currentValue'");
    
    // ✅ NIE NADPISUJ JEŚLI CONTROLLER MA JUŻ PRAWIDŁOWĄ WARTOŚĆ
    if (_controller.text.isNotEmpty && _controller.text != planName) {
      print("  ⚠️ Skipping override - controller already has value: '${_controller.text}'");
      return;
    }
    
    if (_controller.text != planName) {
      _controller.text = planName;
      _currentValue = planName;
      print("📝 Controller value set to: '$planName'");
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(planName.trim());
        }
      });
    }
  }

  void _setControllerValue(String value) {
    if (_controller.text != value) {
      _controller.text = value;
      _currentValue = value;
      
      // ✅ WYWOŁAJ CALLBACK PRZEZ PostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(value.trim());
        }
      });
    }
  }

  void setValue(String value) {
    print("📝 PlanTitleField.setValue called with: '$value'");
    if (_controller.text != value) {
      _controller.text = value;
      _currentValue = value;
      print("📝 Controller updated to: '$value'");
      
      // ✅ WYWOŁAJ CALLBACK PRZEZ PostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(value.trim());
        }
      });
    }
  }

  // ✅ POPRAWIONA METODA _onTextChanged - OPÓŹNIJ CALLBACK
  void _onTextChanged() {
    final newValue = _controller.text;
    if (_currentValue != newValue) {
      _currentValue = newValue;
      
      // ✅ OPÓŹNIJ CALLBACK ABY UNIKNĄĆ setState PODCZAS BUILD
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(newValue.trim());
          //print("📝 Plan title changed: '$newValue' (via PostFrameCallback)");
        }
      });
    }
  }

  void clear() {
    _setControllerValue("");
  }

  String get currentValue => _currentValue.trim();

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nazwa planu treningowego",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        TextField(
          controller: _controller, //  UŻYJ WEWNĘTRZNEGO KONTROLERA
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLength: 50,
          decoration: InputDecoration(
            hintText: widget.isEditMode 
                ? "Edytuj nazwę planu..." 
                : "Wprowadź nazwę planu...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            prefixIcon: Icon(
              widget.isEditMode ? Icons.edit : Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
           // errorText: widget.errorText,
          ),
        ),
        
        //  INFORMACJA O TRYBIE EDYCJI
        if (widget.isEditMode && widget.editPlanName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Edytujesz plan: ${widget.editPlanName}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}


extension PlanTitleFieldExtension on GlobalKey<PlanTitleFieldState> {
  String? get currentValue => currentState?.currentValue;
  void clear() => currentState?.clear();
  void setValue(String value) => currentState?.setValue(value);
}