import java.lang.*;

public class Player {
	String playerName;
	int score;

	// constructor
	public Player(int value, String name) {
		score = value;
		playerName = name;
	}

	public int resetScore() {
		score = 0;

    return 0;
	}

	public int updateScore(int a) {
		score = score + a;

    return score;
	}
}
