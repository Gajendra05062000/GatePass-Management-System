function printPage(){
   var printButton = document.getElementById("print");
        //Set the print button visibility to 'hidden' 
        printButton.style.visibility = 'hidden';
        //Print the page content

window.print();
printButton.style.visibility = 'visible';

}