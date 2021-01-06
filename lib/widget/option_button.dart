import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionButton extends StatefulWidget {
  final String title;
  final Color firstColor;
  final Color secondColor;
  final Color thirdColor;
  final String image;
  final Function callback;

  OptionButton({this.title, this.firstColor, this.secondColor, this.thirdColor, this.image, this.callback});

  @override
  _OptionButtonState createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1),
        child: InkWell(
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 24,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(6), right: Radius.zero),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.1, 0.4, 0.9],
                          colors: [
                            widget.firstColor,
                            widget.secondColor,
                            widget.thirdColor,
                          ],
                        ),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          image: AssetImage(widget.image),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '     ${widget.title}',
                  // style: TextStyle(fontSize: 24, color: Colors.white,),
                  style: GoogleFonts.ptSerif(
                    textStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: widget.callback,
        ),
      ),
    );
  }
}
