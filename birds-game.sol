pragma solidity ^0.5.8;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    /*function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }*/
}

contract birdsGame {
    using SafeMath for uint256;
    
    uint256[] moves;
    uint256 public price = 0;
    uint256 public solutionTime = 0;
    uint256 public allowedTime = 30;
    uint256 public creationTime;
    uint256 public expirationTime;
    uint256 public timeFrame = 24 hours;
    address payable public creator;
    address payable public challanger;
    bool public stake;
    
    enum states { Created, Started, Finished, Expired }
    states stateOfGame;

    struct Bird {
        string nameOfBrid;
        uint256 timeToFly;
        bool flewOver;
    }
    
    mapping (uint => Bird) birds;

    constructor(address payable _challanger, bool _stake, uint256 _time) public payable {
        
        creator = msg.sender;
        challanger = _challanger;
        price = msg.value;
        stake = _stake;
        stateOfGame = states.Created;
        creationTime = now;
        
        if (_time > 0)  timeFrame = _time;
        expirationTime = creationTime.add(timeFrame);
        
        birds[0] = Bird('red', 1, false);
        birds[1] = Bird('yellow', 3, false);
        birds[2] = Bird('black', 6, false);
        birds[3] = Bird('white', 8, false);
        birds[4] = Bird('big', 12, false);
    }
    
    modifier onlyChallanger() {
        require(msg.sender == challanger);
        _;
    }
    
    modifier onlyCreator() {
        require(msg.sender == creator);
        _;        
    }
    
    function acceptGame() public onlyChallanger {
        require(now < expirationTime, "Game already expired!");
        stateOfGame = states.Started;
    }
     
    function submitMove() public onlyChallanger  {
        // check specific move
    } 
    
    function submitGame(uint256[] memory _moves) public onlyChallanger returns (bool) {

        // require(stateOfGame == states.Started);

        uint256 totalTime = 0;
        uint256 currentMove = 0;
        
        uint256 swingOne = 0;
        uint256 swingTwo = 0;
        
        // loop through all the moves;
        for (uint256 i = 0; i < _moves.length; i++) {
            currentMove = currentMove.add(1);

            // check that after each two birds are transferred one always goes back!
            if (currentMove == 3) {
                
                require(birds[_moves[i]].flewOver, "you are trying to get back the bird that is not transferred yet");
        
                // transfer one bird back
                currentMove = 0;
                birds[_moves[i]].flewOver = false;
                totalTime = totalTime.add(birds[_moves[i]].timeToFly);

                
            } else {

                if(currentMove == 1) {
                    swingOne = _moves[i];
                }

                if(currentMove == 2) {
                    swingTwo = _moves[i];
                    
                    // check that both birds are not flew over
                    require(!birds[swingOne].flewOver);
                    require(!birds[swingTwo].flewOver);
                    
                    if (birds[swingOne].timeToFly > birds[swingTwo].timeToFly) totalTime = totalTime.add(birds[swingOne].timeToFly);
                    else totalTime = totalTime.add(birds[swingTwo].timeToFly);
                    
                    // transfer birds over solutuon
                    birds[swingOne].flewOver = true;
                    birds[swingTwo].flewOver = true;
                    
                }
            }
        }
        
        for (uint256 bird = 0; bird < 5; bird++) {
            // require(birds[bird].flewOver, "Not all the birds are transferred!");
            if (!birds[bird].flewOver) incorrectSolution();
        }
        
        solutionTime = totalTime;
        if (totalTime <= allowedTime) {
            awardPrice();
            return true;
        }
        
        incorrectSolution();
        return false;
    }
    
    function incorrectSolution() internal {
        if (stake) creator.transfer(address(this).balance);
    }
    
    function switchBird(Bird memory _bird) internal pure {
        _bird.flewOver = !_bird.flewOver;
    }
    
    function awardPrice() internal {
        // require(stateOfGame == states.Started, "Game not started!");
        // require(now < expirationTime, "Game already expired!");
        // stateOfGame = states.Finished;
        challanger.transfer(address(this).balance);
        selfdestruct(challanger);
    }
    
    function claimLoss() public onlyCreator {
        require(now > expirationTime);
        // creator.transfer(address(this).balance);
        selfdestruct(creator);
    }
    
    function resetGame() public onlyChallanger {
        
    }
    

    
}