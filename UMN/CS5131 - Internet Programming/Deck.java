import java.awt.*;
import java.applet.*;

public class Deck {
	private Card Cards [] = new Card [53];  // to store the deck
	private Applet myApplet;
	private boolean isHidden;

	// constructor
	public Deck(Applet apCard) {
    isHidden = true;
    myApplet = apCard;
		for (int i = 0; i < 53; i++) {
       	 	Cards[i] = new Card(i, apCard);
		}
    }

  public void setHidden(boolean hidden) {
    isHidden = hidden;
  }

	// shuffle the deck
	public void Shuffle () {
		for (int i = 0; i < 52; i ++) {
			int j = (int) (Math.random()*52);
			Card dummy = Cards[i];
			Cards[i] = Cards[j];
			Cards[j] = dummy;
			}
		}


	// draw the card
	public void drawDeck (Graphics g) {
		for (int i = 0; i < 3; i++) {
			if (isHidden) {
 				g.drawImage(Cards[52].Face, i * 75, 150, myApplet);
				g.drawImage(Cards[52].Face, (i * 75) + 400, 150, myApplet);
			}
			else {
				g.drawImage(Cards[i].Face, i * 75, 150, myApplet);
				g.drawImage(Cards[i + 3].Face, (i * 75) + 400, 150, myApplet);
  			}
		}
	}

  public int getPlayerOneScore() {
    return Cards[0].value + Cards[1].value + Cards[2].value;
  }

  public int getPlayerTwoScore() {
    return Cards[3].value + Cards[4].value + Cards[5].value;
  }
}
