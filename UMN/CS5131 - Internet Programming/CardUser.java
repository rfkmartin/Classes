import java.io.*;

public class CardUser {
	
	public static void main( String[] args) {
		Deck myDeck = new Deck();

		myDeck.printDeck();

		myDeck.Shuffle();

		myDeck.printDeck();
	}

}
