var machine = require("./machine");
var assert = require("assert");

// I'd normally use mocha but come on, that's just an exercise - why add dependencies?
function testSuite(withdraw) {
    // successful scenarios
    assert.deepStrictEqual(withdraw(0), [0, 0, 0, 0]);
    assert.deepStrictEqual(withdraw(10), [0, 0, 0, 1]);
    assert.deepStrictEqual(withdraw(20), [0, 0, 1, 0]);
    assert.deepStrictEqual(withdraw(30), [0, 0, 1, 1]);
    assert.deepStrictEqual(withdraw(40), [0, 0, 2, 0]);
    assert.deepStrictEqual(withdraw(50), [0, 1, 0, 0]);
    assert.deepStrictEqual(withdraw(60), [0, 1, 0, 1]);
    assert.deepStrictEqual(withdraw(70), [0, 1, 1, 0]);
    assert.deepStrictEqual(withdraw(80), [0, 1, 1, 1]);
    assert.deepStrictEqual(withdraw(90), [0, 1, 2, 0]);
    assert.deepStrictEqual(withdraw(100), [1, 0, 0, 0]);
    assert.deepStrictEqual(withdraw(500), [5, 0, 0, 0]);
    assert.deepStrictEqual(withdraw(780), [7, 1, 1, 1]);
    assert.deepStrictEqual(withdraw(11110), [111, 0, 0, 1]);

    // failures
    try {
        withdraw(55);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "Cannot deliver 55 in available notes. Withdrawal amount must end with a zero (10, 80, ...)")
    }

    try {
        withdraw(8521);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "Cannot deliver 8521 in available notes. Withdrawal amount must end with a zero (10, 80, ...)")
    }

    try {
        withdraw();
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "undefined is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }

    try {
        withdraw(null);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "null is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }

    try {
        withdraw("4.50");
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "4.50 is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }


    try {
        withdraw("420");
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "420 is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }

    try {
        withdraw(Number.NaN);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "NaN is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }

    try {
        withdraw(Infinity);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "Infinity is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }

    try {
        withdraw(4.50);
        assert.fail("Should not be able to withdraw that");
    } catch (err) {
        assert.strictEqual(err.msg, "4.5 is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)")
    }
}

testSuite(machine.withdraw);
testSuite(machine.fastWithdraw);