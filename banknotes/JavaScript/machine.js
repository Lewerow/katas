// The problem solved here is an ultra-simple version of change-making problem
// Details of it can be found in https://en.wikipedia.org/wiki/Change-making_problem or in math books
// Optimal algorithm for dealing with "canonical" coin/note systems (1, 2, 5, 10 or 10, 20, 50, 100) is greedy
//
// For the proof we could go to textbooks, or we can just write it here, because why not.
// Problem: Deliver the lowest number of notes (with values: $100, $50, $20, $10) that sum up to given value
// Solution:
//   Let x - machine amount (integer)
//   x >= 0 and x % 10 = 0 <- preconditions
//   Let k100 - number of $100 notes, k50 - number of $50 notes, k20 - number of $20 notes, k10 - number of $10 notes
//   k100, k50, k20, k10 >= 0 <- postcondition
//   Then:
//   k100 = ⌊ x / 100 ⌋,
//   k50 = ⌊ (x - 100*k100) / 50 ⌋,
//   k20 = ⌊ (x - 100*k100 - 50*k50) / 20 ⌋,
//   k10 = ⌊ (x - 100*k100 - 50*k50 - 20*k20) / 10 ⌋
// Theorem: Optimal algorithm is greedy
// Proof:
// We need to prove two things:
// 1) Greedy algorithm is able to deliver a solution whenever the problem is solvable
// 2) Solution delivered by greedy algorithm will be always optimal
//
// To prove 1) we first show that our preconditions indeed hold (solutions exist only when x >= 0 and x % 10 = 0)
// Lemma: Problem is solvable only for non-negative x divisible by 10.
// Proof:
// x = 100*k100 + 50*k50 + 20*k20 + 10*k10
// x = 10*(10*k100 + 5*k50 + 2*k20 + k10)
// since x must be an integer, this necessarily means that it can be written in form:
// x = 10 * a <- which proves that x % 10 = 0
// now for x > 0:
// since 10 > 1, 5 > 1, 2 > 1 and 1 = 1 we can drop constants and go for inequality:
// x >= 10*(k100 + k50 + k20 + k10)
// now recall that k100 >= 0, k50 >= 0, k20 >= 0 and k10 >= 0, which means that we can substitute
// x >= 10*(0+0+0+0)
// x >= 0 <- this is the second part of lemma proof.
//
// Our preconditions are proven, great!

// Now to the actual proof of optimality
// for every pair of notes we find their lcm (least common multiple)
// in square brackets we note number of required notes with given value
// lcm(100, 50) = 100 {1, 2}, lcm(100, 20) = 100 {1, 5}, lcm(100, 10) = 100 {1, 10}
// lcm(50, 20) = 100 {2, 5}, lcm(50, 10) = 50 {1, 5}, lcm(20, 10) = 20 {1, 2}
// this means that the least common multiplier for all is 100, which can be acquired with a single $100 note
// since we do not have a note of bigger value and we cannot use less than one note for a payment,
// everything above $100 should be paid using $100 notes first and then paying the rest
// rest will be x % 100 - now we repeat the above process without $100 note:
// lcm(50, 20) = 100 {2, 5}, lcm(50, 10) = 50 {1, 5}, lcm(20, 10) = 20 {1, 2}
// now we have a little ambiguity, because the common multiple is bigger than x % 100
// we can really just list the possible values of x % 100 here:
// 0, 10, 20, 30, 40, 50, 60, 70, 80, 90
// it wouldn't be hard to just list the possible combinations here and be done with the proof
// which by the way may be the fastest implementation (single lookup instead of multiple divisions, conditions etc.)
// anyway, we can also see that we have two ranges:
// 0 + (10, 20, 30, 40) and 50 + (10, 20, 30, 40)
// since 50 can be obtained using a single $50 note, that's the best if the rest is bigger than 50
// the remaining rests - 10, 20, 30, 40 - can be again solved using same method, i.e. lcm(20, 10) = 20 {1, 2}
// then anything that is at least $20 starts with taking as many $20 bills as possible, then the rest is filled with $10
// therefore we proved that all x that fulfill preconditions can be represented this way and that it is not possible
// to obtain same sums with smaller number of notes.
// Anyway, that's the proof - a little handwaving there in the end, but I hope it was convincing enough.
// Even if not, at least I had some fun writing it. Have a nice time reviewing the implementation!

var machine = function() {
    function NoteUnavailableException(amount) {
        this.msg = `Cannot deliver ${amount} in available notes. Withdrawal amount must end with a zero (10, 80, ...)`;
    }


    function InvalidArgumentException(amount) {
        this.msg = `${amount} is not deliverable. Withdrawal amount must be a positive integer ending with 0 (10, 80, ...)`
    }

    var notes = [100, 50, 20, 10];

    // because gcd(100, 50, 20, 10) = 10
    var commonDivisor = 10;

    function checkPreconditions(withdrawalAmount) {
        if (!Number.isInteger(withdrawalAmount)) {
            throw new InvalidArgumentException(withdrawalAmount);
        }
        if (withdrawalAmount < 0) {
            throw new InvalidArgumentException(withdrawalAmount);
        }

        // this one depends on available notes - the task has fixed set, so it's simple
        // for an arbitrary set of notes it'd be much more complex
        if (withdrawalAmount % commonDivisor) {
            throw new NoteUnavailableException(withdrawalAmount);
        }
    }

    function withdraw(withdrawalAmount) {
        checkPreconditions(withdrawalAmount);

        // greedy algorithm works in this case, so we'll go for it because it's simple
        // to see more explaination see top of the file
        // that's technically a scan, but ECMAScript doesn't provide a nice shortcut for scan, so let's go old school
        var amounts = [];
        var left = withdrawalAmount;
        for (var n of notes) {
            amounts.push(Math.floor(left / n));
            left = left % n;
        }

        return amounts;
    }

    var lookup = {
        0: [0, 0, 0],
        10: [1, 0, 0],
        20: [0, 1, 0],
        30: [1, 1, 0],
        40: [0, 2, 0],
        50: [0, 0, 1],
        60: [1, 0, 1],
        70: [0, 1, 1],
        80: [1, 1, 1], // to differentiate between algorithms, because why not
        90: [0, 2, 1]
    };
    // it's a guess that this will be faster
    // I doubt it would make a difference in any real-world scenario
    // but anyway, I wanted to try it out
    function fastWithdraw(withdrawalAmount) {
        checkPreconditions(withdrawalAmount);
        var hundreds = Math.floor(withdrawalAmount / 100);
        var rest = Math.floor(withdrawalAmount % 100);
        return lookup[rest].concat(hundreds).reverse();
    }

    return {
        notes: notes,
        withdraw: withdraw,
        fastWithdraw: fastWithdraw
    }
};

module.exports = machine();