import java.applet.*;
import java.awt.*;
import java.awt.event.*;

public class CardGame extends Applet implements ActionListener {
	Deck myDeck;
	Button shufButton, rstButton, showButton;
	Player playerOne, playerTwo;
	String playerOneName;
	String playerTwoName;
  TextField playerOneScoretf, playerTwoScoretf;
	int score = 0;

	public void init() {
		setBackground(Color.white);
		myDeck = new Deck(this);
		myDeck.Shuffle();

		playerOneName = getParameter("playerOneName");
		playerTwoName = getParameter("playerTwoName");

		playerOne = new Player(score, playerOneName);
		playerTwo = new Player(score, playerTwoName);

		setLayout(new GridLayout(4,1));

		Panel p1 = new Panel();
		p1.setLayout(new GridLayout(1, 3));

		shufButton = new Button("Shuffle");
		shufButton.addActionListener(this);
		p1.add(shufButton);

		showButton = new Button("Show");
		showButton.addActionListener(this);
		p1.add(showButton);

		rstButton = new Button("Reset");
		rstButton.addActionListener(this);
		p1.add(rstButton);
		add(p1);

		Panel p2 = new Panel();
		p2.setLayout(new GridLayout(1, 4));
		Label playerOneNamelbl = new Label(playerOne.playerName);
		p2.add(playerOneNamelbl);
		playerOneScoretf = new TextField("" + playerOne.score, 4);
		playerOneScoretf.setEditable(false);
		p2.add(playerOneScoretf);
		Label playerTwoNamelbl = new Label(playerTwo.playerName);
		p2.add(playerTwoNamelbl);
		playerTwoScoretf = new TextField("" + playerTwo.score, 4);
		playerTwoScoretf.setEditable(false);
		p2.add(playerTwoScoretf);
		add(p2);

		repaint();

	}

	public void paint(Graphics g) {
		myDeck.drawDeck(g);
    }


	public void actionPerformed (ActionEvent e) {
		if (e.getSource() == shufButton) {
			myDeck.setHidden(true);
			myDeck.Shuffle();
			repaint();
		}
		if (e.getSource() == showButton) {
			myDeck.setHidden(false);
		  playerOneScoretf.setText("" + playerOne.updateScore(myDeck.getPlayerOneScore()));
			playerTwoScoretf.setText("" + playerTwo.updateScore(myDeck.getPlayerTwoScore()));
			repaint();
		}
		if (e.getSource() == rstButton) {
			myDeck.setHidden(true);
		  playerOneScoretf.setText("" + playerOne.resetScore());
			playerTwoScoretf.setText("" + playerTwo.resetScore());
 			repaint();
		}

		repaint();
	}

}
