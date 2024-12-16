part of "../customized_keyboard.dart";

class KeyBoardMomo extends CustomKeyboard {
  static const double _kHeight = 220;
  static const _key = 'KeyBoardMomo';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: _kHeight,
        color: const Color(0xD0EFEFEF),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.clear(),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('AC')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('7'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('7')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('4'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('4')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('1'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('1')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('000'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('000')),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.operator('/'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('/')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('8'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('8')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('5'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('5')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('2'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('2')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.operator('.'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('.')),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.operator('x'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('x')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('9'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('9')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('6'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('6')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('3'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('3')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.character('0'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('0')),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.deleteOne(),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('⌫')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.operator('-'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('-')),
                    ),
                  ),
                  Expanded(
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.operator('+'),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('+')),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CustomKeyboardKey(
                      keyEvent: const CustomKeyboardEvent.calculate(),
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: const Center(child: Text('=')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get height => _kHeight;

  @override
  String get name => _key;
}
