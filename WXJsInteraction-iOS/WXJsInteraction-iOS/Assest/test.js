//周长计算
var perimeterCalculation = function() {
    width = parseFloat(document.getElementById("widthInput").value);
    height = parseFloat(document.getElementById("heightInput").value);
    return (width+height)*2;
}
//面积计算
var areaCalculation = function(width,height) {
    return width * height;
}
