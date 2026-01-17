import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/helpers.dart';

class PickerDialogStyle {
  final Color? backgroundColor;
  final TextStyle? countryCodeStyle;
  final TextStyle? countryNameStyle;
  final Widget? listTileDivider;
  final EdgeInsets? listTilePadding;
  final EdgeInsets? padding;
  final Color? searchFieldCursorColor;
  final InputDecoration? searchFieldInputDecoration;
  final EdgeInsets? searchFieldPadding;
  final double? width;
  final Color? searchFieldBorderColor;
  final Color? searchFieldFocusedBorderColor;
  final Color? searchFieldFillColor;
  final TextStyle? searchFieldTextStyle;
  final Color? searchFieldHintColor;
  final BorderRadius? searchFieldBorderRadius;
  final Color? grabberColor;
  final Widget? searchFieldPrefixIcon;

  PickerDialogStyle({
    this.backgroundColor,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.padding,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.width,
    this.searchFieldBorderColor,
    this.searchFieldFocusedBorderColor,
    this.searchFieldFillColor,
    this.searchFieldTextStyle,
    this.searchFieldHintColor,
    this.searchFieldBorderRadius,
    this.grabberColor,
    this.searchFieldPrefixIcon,
  });
}

class CountryPickerDialog extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final PickerDialogStyle? style;
  final String languageCode;
  final double heightFraction;

  const CountryPickerDialog({
    Key? key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
    this.heightFraction = 1,
  }) : super(key: key);

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a.localizedName(widget.languageCode).compareTo(b.localizedName(widget.languageCode)),
      );

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final mediaHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    final bottomPadding = MediaQueryData.fromView(View.of(context)).padding.bottom;
    const defaultPrefixIcon = Padding(
      padding: EdgeInsetsDirectional.only(start: 10.0, end: 4.0),
      child: Icon(
        Icons.search,
        color: Colors.black,
        size: 20,
      ),
    );

    return Container(
      height: mediaHeight * widget.heightFraction,
      margin: EdgeInsets.only(top: topPadding, bottom: (keyboardHeight > 0 ? keyboardHeight : 0)),
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top grabber
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: widget.style?.grabberColor ?? const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search TextField with custom styling
          Padding(
            padding: widget.style?.searchFieldPadding ?? const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              cursorColor: widget.style?.searchFieldCursorColor ?? const Color(0xFF231F20),
              style: widget.style?.searchFieldTextStyle ??
                  const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF231F20),
                  ),
              decoration: InputDecoration(
                fillColor: widget.style?.searchFieldFillColor ?? Colors.transparent,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                hintText: widget.searchText,
                hintStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: widget.style?.searchFieldHintColor ?? const Color(0xFF666666),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 24, maxHeight: 24),
                prefixIcon: widget.style?.searchFieldPrefixIcon ?? defaultPrefixIcon,
                enabledBorder: OutlineInputBorder(
                  borderRadius: widget.style?.searchFieldBorderRadius ?? const BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(
                    color: widget.style?.searchFieldBorderColor ?? const Color(0xFFD6D6D6),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: widget.style?.searchFieldBorderRadius ?? const BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(
                    color: widget.style?.searchFieldFocusedBorderColor ?? const Color(0xFF231F20),
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: widget.style?.searchFieldBorderRadius ?? const BorderRadius.all(Radius.circular(12.0)),
                ),
                counterText: '',
              ),
              onChanged: (value) {
                _filteredCountries = widget.countryList.stringSearch(value)
                  ..sort(
                    (a, b) => a.localizedName(widget.languageCode).compareTo(b.localizedName(widget.languageCode)),
                  );
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          // Countries List
          Expanded(
            child: ListView.separated(
              padding: widget.style?.padding ??
                  EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12 + (keyboardHeight > 0 ? 0 : bottomPadding),
                  ),
              itemCount: _filteredCountries.length,
              separatorBuilder: (ctx, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: widget.style?.listTileDivider ??
                    const Divider(
                      thickness: 1,
                      height: 1,
                      color: Color(0xFFE7E7E7),
                    ),
              ),
              itemBuilder: (ctx, index) {
                final country = _filteredCountries[index];
                return InkWell(
                  onTap: () {
                    _selectedCountry = country;
                    widget.onCountryChanged(_selectedCountry);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      kIsWeb
                          ? Image.asset(
                              'assets/flags/${country.code.toLowerCase()}.png',
                              package: 'intl_phone_field',
                              width: 32,
                            )
                          : Text(
                              country.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          country.localizedName(widget.languageCode),
                          style: widget.style?.countryNameStyle ??
                              const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFF231F20),
                              ),
                        ),
                      ),
                      Text(
                        '+${country.dialCode}',
                        style: widget.style?.countryCodeStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFF231F20),
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
