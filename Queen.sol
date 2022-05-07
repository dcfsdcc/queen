pragma solidity 0.6.12;
import '@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol';
import '@pancakeswap/pancake-swap-lib/contracts/GSN/Context.sol';
import '@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol';
import '@pancakeswap/pancake-swap-lib/contracts/utils/Address.sol';
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {

}

interface IUniswapV2Pair {

    function sync() external;
}
contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

contract QueenNew is BEP20 {

    uint  buyFeeRate = 10;
    uint  burnRate = 4;
    uint  inviteRewardRate = 6;
    uint256  _inviteThreshlod;  // 500u

    uint  sellFeeRate = 0;
    uint  returnLiquidRate = 4;
    uint  fundRate = 1;

    uint  parentOneRelationRate = 2;
    uint  parentTwoRelationRate = 1;
    uint  parentThreeRelationRate = 1;
    uint  parentFourRelationRate = 1;
    uint  parentFiveRelationRate = 1;

    uint256 internal _minSupply;
    uint256 _burnedAmount;

    address burnAddress = address(1);

    mapping(address => uint256) public memberInviter;
    mapping(address => address) public inviter;

    IUniswapV2Router02  router;
    address  usdtAddress;

    address  foundationAddress = 0x4DF2D257c40335d0D4EdcbDb917d931c1359b5AF;

    mapping(address => bool)  uniswapV2PairList;

    address  uniswapV2PairUsdt;

    constructor(address _usdtAddress,
        address _router) public BEP20("QUEEN", "QUEEN") {

        router = IUniswapV2Router02(_router);

        usdtAddress = _usdtAddress;

        uniswapV2PairUsdt = IUniswapV2Factory(router.factory())
        .createPair(address(this), usdtAddress);

        uniswapV2PairList[uniswapV2PairUsdt] = true;

        _mint(msg.sender, 21000 * (10 ** uint256(decimals())));

        _minSupply = 5000 * (10 ** uint256(decimals()));
        _inviteThreshlod = 300 * (10 ** uint256(IBEP20(usdtAddress).decimals()));// 500 * (10 ** uint256(IBEP20(usdtAddress).decimals()));

    }

    function calculateSellFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(sellFeeRate).div(
            10 ** 2
        );
    }

    function calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(buyFeeRate).div(
            10 ** 2
        );
    }

    function addMemberInviter(address _inviter, address child) private {

        address parent = inviter[child];
        if (parent == address(0) && _inviter != child) {
            inviter[child] = _inviter;
            memberInviter[_inviter] = memberInviter[_inviter].add(1);

        }
    }

    function _assignInviteReward(uint256 inviteRewardAmount,address sender) private returns(uint256 inviteRewardAssigned){
        uint256 parentOneRelationAmount = inviteRewardAmount.mul(parentOneRelationRate).div(6);
        uint256 parentTwoRelationAmount = inviteRewardAmount.mul(parentTwoRelationRate).div(6);
        uint256 parentThreeRelationAmount = inviteRewardAmount.mul(parentThreeRelationRate).div(6);
        uint256 parentFourRelationAmount = inviteRewardAmount.mul(parentFourRelationRate).div(6);
        uint256 parentFiveRelationAmount = inviteRewardAmount.mul(parentFiveRelationRate).div(6);

        address parentOne = inviter[sender];

        if (parentOne != address(0)) {
            _balances[parentOne] = _balances[parentOne].add(parentOneRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentOneRelationAmount);
            emit Transfer(sender, parentOne, parentOneRelationAmount);
        }
        address parentTwo = inviter[parentOne];
        if (parentTwo != address(0) && memberInviter[parentTwo] >= 2) {
            _balances[parentTwo] = _balances[parentTwo].add(parentTwoRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentTwoRelationAmount);
            emit Transfer(sender, parentTwo, parentTwoRelationAmount);
        }
        address parentThree = inviter[parentTwo];
        if (parentThree != address(0)  && memberInviter[parentThree] >= 3) {
            _balances[parentThree] = _balances[parentThree].add(parentThreeRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentThreeRelationAmount);
            emit Transfer(sender, parentThree, parentThreeRelationAmount);
        }
        address parentFour = inviter[parentThree];
        if (parentFour != address(0)  && memberInviter[parentThree] >= 4) {
            _balances[parentFour] = _balances[parentFour].add(parentFourRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentFourRelationAmount);
            emit Transfer(sender, parentFour, parentFourRelationAmount);
        }
        address parentFive = inviter[parentFour];
        if (parentFive != address(0)  && memberInviter[parentThree] >= 5) {
            _balances[parentFive] = _balances[parentFive].add(parentFiveRelationAmount);
            inviteRewardAssigned = inviteRewardAssigned.add(parentFiveRelationAmount);
            emit Transfer(sender, parentFive, parentFiveRelationAmount);
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        uint fee = 0;
        //not sell or  buy
        if (!uniswapV2PairList[recipient] && !uniswapV2PairList[sender]
            && sender != address(router) && recipient != address(router)
        ) {
            uint256 toBalance = balanceOf(recipient);

            if (toBalance == 0) {
                addMemberInviter(sender, recipient);
            }
        }
        if (uniswapV2PairList[recipient] || uniswapV2PairList[sender]) {
            uint256 leftAmount = totalSupply().sub(_burnedAmount);

            if (leftAmount > _minSupply) {

                if (uniswapV2PairList[recipient]) {
                    fee = calculateSellFee(amount);
                }

                if (uniswapV2PairList[sender]) {
                    fee = calculateBuyFee(amount);
                }

                uint256 leftAmountSubFee = leftAmount.sub(fee);
                if (leftAmountSubFee < _minSupply) {
                    fee = leftAmount.sub(_minSupply);
                }

                if(fee>0){
                    if (uniswapV2PairList[recipient]) { //sell
                        uint256 returnLiquidAmount = fee.mul(returnLiquidRate).div(5);

                        uint256 fundAmount = fee.mul(fundRate).div(5);

                        _balances[uniswapV2PairUsdt] = _balances[uniswapV2PairUsdt].add(returnLiquidAmount);
                        emit Transfer(sender, uniswapV2PairUsdt, returnLiquidAmount);

    //                    IUniswapV2Pair(uniswapV2PairUsdt).sync();
                        _balances[foundationAddress] = _balances[foundationAddress].add(fundAmount);
                        emit Transfer(sender, foundationAddress, fundAmount);
                    }

                    if (uniswapV2PairList[sender]) { // buy
                        // 500u

                        uint256 burnAmount = fee.mul(burnRate).div(10);
                        _balances[burnAddress] = _balances[burnAddress].add(burnAmount);
                        _burnedAmount = _burnedAmount.add(burnAmount);
                        emit Transfer(sender, burnAddress, burnAmount);


                        uint256 inviteRewardAmount = fee.mul(inviteRewardRate).div(10);
                        uint256 inviteRewardAssigned = 0;
                        if (IBEP20(uniswapV2PairUsdt).totalSupply() > 0 && balanceOf(uniswapV2PairUsdt) > 1 * 10 ** 18) {
                            address[] memory t = new address[](2);

                            t[0] = address(this);
                            t[1] = usdtAddress;

                            uint256[] memory amounts = router.getAmountsOut(1 * (10 ** uint256(decimals())), t);
                            uint256 newPrice = amounts[1];

                            uint256 amountUsdt = amount.mul(newPrice).div((10 ** uint256(decimals())));

                            if (amountUsdt >= _inviteThreshlod) {
                                // buy from  pair,  pair  to  user,compute user's  invite relations
                                inviteRewardAssigned = _assignInviteReward( inviteRewardAmount, recipient);
                            }
                        }

                        if (inviteRewardAmount > inviteRewardAssigned) {
                            uint256 inviteRewardBurn = inviteRewardAmount.sub(inviteRewardAssigned);
                            _balances[burnAddress] = _balances[burnAddress].add(inviteRewardBurn);
                            _burnedAmount = _burnedAmount.add(inviteRewardBurn);
                            emit Transfer(sender, burnAddress, inviteRewardBurn);
                        }
                    }
                }
            }
        }

        uint256 acceptAmount = amount - fee;

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(acceptAmount);

        emit Transfer(sender, recipient, acceptAmount);
    }

    function setBuyFeeRate(uint _buyFeeRate)external onlyOwner{
        buyFeeRate = _buyFeeRate;
    }

    function setSellFeeRate(uint _sellFeeRate)external onlyOwner{
        sellFeeRate = _sellFeeRate;
    }

    function setPair(address pair)external onlyOwner{
        uniswapV2PairUsdt = pair;
    }

    function minSupply() public view  returns (uint256) {
        return _minSupply;
    }

    function burnedAmount() public view  returns (uint256) {
        return _burnedAmount;
    }

    function inviteThreshlod() public view  returns (uint256) {
        return _inviteThreshlod;
    }

    function setInviteThreshlod(uint inviteThreshlodParam)external onlyOwner{
        _inviteThreshlod = inviteThreshlodParam;
    }

    function setFoundationAddress(address _foundationAddress) external onlyOwner {
        foundationAddress = _foundationAddress;
    }

    // function mint(address user, uint256 amount) public onlyOwner returns (bool) {
    //     _mint(user, amount);
    //     return true;
    // }
}
