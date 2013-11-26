import java.awt.*;
import java.applet.*;

public class Card {
	public int value;
	public Image Face;

	//constructor
	public Card(int whatcard, Applet apCard) {
		value = (whatcard % 13) + 1;
		Face = apCard.getImage(apCard.getDocumentBase(), "img/" + (whatcard + 1)
		+ ".gif");
	}
}
