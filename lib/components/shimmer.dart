import 'package:base_code/package/config_packages.dart';

class ShimmerClass extends StatelessWidget {
 final double? height;
 final double? width;
 final bool? isHorizontal;
 final int?  index;

   const ShimmerClass({super.key, this.height, this.width,this.isHorizontal, this.index });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 2000),
      child: Container(
        height:height?? 120,
        width:width?? MediaQuery.of(context).size.width,
        margin:isHorizontal==true?  EdgeInsets.only(
      left: index == 0 ? 0 : 16,
      ):const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class ShimmerListClass extends StatelessWidget {
  final int length;
  final double? height;
  final double? width;
  final bool? isHorizontal;

  const ShimmerListClass({super.key, required this.length, this.height,this.isHorizontal,this.width});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

        padding:  isHorizontal==true?const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16): const EdgeInsets.symmetric(vertical: 16),
        physics: const ScrollPhysics(),
        itemCount: length,
        scrollDirection:isHorizontal==true?Axis.horizontal: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) {
      return ShimmerClass(height: height,width:width,index: index,isHorizontal: isHorizontal,);
    });
  }
}
