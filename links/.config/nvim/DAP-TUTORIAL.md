# DAP Debugging Tutorial - Hands-On Guide

**Goal:** Learn Neovim's debugger (DAP) by debugging a real Rust test from your Advent of Code solution.

**File:** `/Users/augustin/dev/perso/aoc-2025/src/bin/01.rs`

---

## 🎯 Tutorial Overview

You'll learn to:
1. Set breakpoints in test code
2. Start a debug session for a specific test
3. Step through code line by line
4. Inspect variable values in real-time
5. Use the REPL to evaluate expressions
6. Watch how variables change in loops
7. Navigate the call stack

**Estimated time:** 15-20 minutes

---

## 📋 Prerequisites

1. Build your Rust project with debug symbols:
```bash
cd /Users/augustin/dev/perso/aoc-2025
cargo build --tests
```

2. Open the file in Neovim:
```bash
nvim src/bin/01.rs
```

---

## 🚀 Part 1: Your First Breakpoint (5 min)

### Step 1.1: Navigate to a Test
Let's debug the `test_part_one_custom_input_1` test (starts at line ~73).

**Using Telescope (fastest):**
- Press `<leader>fg` (Space + f + g)
- Type: `test_part_one_custom_input_1`
- Press Enter

**Or scroll manually:**
- Press `73G` (jumps to line 73)

You should see this test:
```rust
#[test]
fn test_part_one_custom_input_1() {
    let result = part_one(
        r#"R50
L100"#,
    );
    assert_eq!(result, Some(2));
}
```

### Step 1.2: Set Your First Breakpoint

1. Move your cursor to the line with `let result = part_one(...)`
2. Press `<leader>db` (Space + d + b)
3. You should see a **red ●** appear in the left margin (sign column)

**What just happened?**
- You set a breakpoint - the debugger will pause execution here
- The red dot confirms the breakpoint is active

### Step 1.3: Start Debugging

Press `F5`

**You'll see a prompt:**
```
Path to executable: /Users/augustin/dev/perso/aoc-2025/target/debug/
```

**What to enter:**
You need to specify which test binary to run. Rust test binaries are named after the file.

Type: `target/debug/deps/01-` then press `Tab` to autocomplete (or find the exact name):

```bash
# Quick way to find the test binary name:
# In another terminal or use :terminal in Neovim
ls -lt target/debug/deps/01-* | head -1
```

The binary name will look like: `01-a1b2c3d4e5f6g7h8`

Full path example:
```
/Users/augustin/dev/perso/aoc-2025/target/debug/deps/01-a1b2c3d4e5f6g7h8
```

**Pro tip:** After the first time, press `F5` then `<leader>dl` to run the last configuration!

### Step 1.4: Observe the Debug UI

Once debugging starts, **the UI automatically opens!**

**Left sidebar shows:**
- **Scopes:** Local variables and their values
- **Breakpoints:** List of all your breakpoints
- **Call Stack:** Function call hierarchy
- **Watches:** Variables you want to monitor

**Bottom panel shows:**
- **REPL:** Interactive Rust console
- **Console:** Program output and debug logs

**Main window:**
- A **yellow arrow (→)** appears on the current line
- Execution is **paused** at your breakpoint

---

## 🔍 Part 2: Inspecting Variables (5 min)

Now you're paused at the breakpoint. The `result` variable hasn't been assigned yet.

### Step 2.1: Step Into the Function

Press `F11` (Step Into)

**What happened?**
- You "stepped into" the `part_one` function
- The yellow → moved to the first line inside `part_one`
- You should now be at: `let amounts = extract_amounts(input);`

### Step 2.2: Check the Input Parameter

Look at the **Scopes** panel (left sidebar) under "Locals":
- You should see `input: &str` with the value `"R50\nL100"`

**Alternative: Hover to Inspect**
1. Move your cursor over the word `input` in the code
2. Press `<leader>dh` (Space + d + h)
3. A floating window shows the variable value!

### Step 2.3: Step Over to Execute the Current Line

Press `F10` (Step Over)

**What happened?**
- `extract_amounts(input)` was called and completed
- The yellow → moved to the next line: `let mut current = 50;`
- Check the Scopes panel - you should now see `amounts: Vec<i32>`!

**Inspect the amounts vector:**
1. In the Scopes panel, look for `amounts`
2. Click the `▸` to expand it (or move cursor and press Space in the debug sidebar)
3. You'll see: `[50, -100]` (the parsed input!)

### Step 2.4: Execute a Few More Lines

Press `F10` three more times to execute:
```rust
let mut current = 50;
let mut zeros = 0;
for amount in amounts {  // ← You'll stop here
```

**Now check the Scopes panel:**
- `amounts: Vec<i32>` = `[50, -100]`
- `current: i32` = `50`
- `zeros: u64` = `0`
- The `for` loop is about to start!

---

## 🔄 Part 3: Debugging Loops (5 min)

You're now at the beginning of a `for` loop. This is where the debugger really shines!

### Step 3.1: Enter the Loop (First Iteration)

Press `F10` (Step Over) to enter the loop

The yellow → should now be at: `current += amount;`

**Check Scopes panel:**
- `amount: i32` = `50` (first value from the vector!)

### Step 3.2: Watch Variables Change

Keep pressing `F10` and watch the Scopes panel after each step:

**After `current += amount;`:**
- `current` changes from `50` to `100`
- Notice the **highlight** in the Scopes panel when a value changes!

**After `current %= 100;`:**
- `current` changes from `100` to `0`
- See it in real-time!

**After `if current == 0 { zeros += 1; }`:**
- `zeros` changes from `0` to `1`

**Virtual Text Feature:**
If you look at the code, you might see **inline variable values** appearing as gray text at the end of lines! This is the virtual text feature showing live values.

### Step 3.3: Continue to Next Iteration

Press `F10` until you loop back to `for amount in amounts {`

Press `F10` again to enter the second iteration

**Check Scopes:**
- `amount: i32` = `-100` (second value!)
- `current: i32` = `0`
- `zeros: u64` = `1`

### Step 3.4: Step Through Second Iteration

Press `F10` to execute `current += amount;`

**Scopes shows:**
- `current` = `-100` (0 + -100)

Press `F10` to execute `if current < 0 { current += 100; }`

**Scopes shows:**
- `current` = `0` (-100 + 100)

Continue stepping through...

---

## 🧪 Part 4: Using the REPL (3 min)

The REPL (Read-Eval-Print Loop) lets you **execute code** while debugging!

### Step 4.1: Open the REPL

Press `<leader>dr` (Space + d + r)

The **REPL panel** at the bottom becomes active.

### Step 4.2: Evaluate Expressions

While paused in the function, try typing these in the REPL:

**Check a variable:**
```rust
current
```
Output: `0` (or whatever the current value is)

**Do math:**
```rust
current + 50
```
Output: `50`

**Check vector length:**
```rust
amounts.len()
```
Output: `2`

**Call a method:**
```rust
amounts.iter().sum::<i32>()
```
Output: `-50` (sum of 50 and -100)

**Pretty cool, right?** You can run arbitrary Rust code in the context of the current scope!

---

## 🎯 Part 5: Call Stack Navigation (2 min)

### Step 5.1: View the Call Stack

Look at the **Call Stack** section in the left sidebar (might need to scroll).

You should see something like:
```
▸ 01::part_one (line 8)
▸ 01::tests::test_part_one_custom_input_1 (line 76)
▸ test::run_test_in_process (core)
...
```

**What is this?**
- The stack shows **how you got here**
- Top = current function (`part_one`)
- Below = caller (`test_part_one_custom_input_1`)

### Step 5.2: Navigate Up the Stack

Click on (or navigate to) `test_part_one_custom_input_1` in the call stack.

**What happens?**
- The main window **jumps to the test function**
- You can see where `part_one` was called from
- The Scopes panel shows variables **from that scope**

Click back on `part_one` to return to the current function.

**When is this useful?**
- When debugging deep call chains
- To see what arguments were passed from the caller
- To understand the execution context

---

## 🏁 Part 6: Advanced Debugging Techniques

### 6.1: Conditional Breakpoints

Let's set a breakpoint that only triggers when `zeros > 0`:

1. Navigate to the line `if current == 0 {`
2. Press `<leader>dB` (Space + d + B) for conditional breakpoint
3. Enter the condition: `zeros > 0`
4. You'll see a **red diamond (◆)** instead of a dot

Press `F5` (Continue) - execution will pause **only** when `zeros > 0`!

### 6.2: Continue to Next Breakpoint

Press `F5` (Continue)

**What happens?**
- Code runs at full speed until the next breakpoint
- Use this to skip over sections you're not interested in

### 6.3: Toggle Debug UI

Press `<leader>du` (Space + d + u)

**What happens?**
- The debug UI closes (more screen space for code!)
- Press again to reopen it

You can keep debugging even with the UI closed - just use the keybindings!

---

## 🎓 Common Debugging Workflows

### Workflow 1: Debug a Failing Test

**Scenario:** `test_part_two_example_1` is failing

1. Navigate to the failing test
2. Set breakpoint on the line calling `part_two`
3. Press `F5`, select the test binary
4. Step through with `F10`/`F11`
5. Watch where the actual result diverges from expected
6. Use REPL to test alternative calculations
7. Fix the bug!

### Workflow 2: Understand Complex Logic

**Scenario:** Don't understand how the `part_two` function works

1. Set breakpoint at `let amounts = extract_amounts(input);`
2. Press `F5` to start debugging
3. Step through the entire function with `F10`
4. Watch variables change in the Scopes panel
5. Use REPL to test assumptions: `amount / 100`, `amount % 100`, etc.
6. Understand the logic by seeing it execute!

### Workflow 3: Track Down Edge Cases

**Scenario:** Function works for most inputs but fails for one

1. Set conditional breakpoint: `amount < -100`
2. Let code run with `F5`
3. Only pauses when the edge case occurs
4. Inspect state when the unusual condition happens

---

## 📝 Complete Keybinding Reference

| Keybinding | Action | When to Use |
|------------|--------|-------------|
| `<leader>db` | Toggle breakpoint | Mark where to pause |
| `<leader>dB` | Conditional breakpoint | Pause only when condition is true |
| `F5` | Start/Continue | Begin debugging or skip to next breakpoint |
| `F10` | Step over | Execute current line, don't enter functions |
| `F11` | Step into | Enter the function being called |
| `F12` | Step out | Exit current function, return to caller |
| `<leader>dh` | Hover variable | See value of variable under cursor |
| `<leader>dp` | Preview | Alternative hover view |
| `<leader>dr` | Open REPL | Execute code interactively |
| `<leader>du` | Toggle debug UI | Show/hide sidebar and panels |
| `<leader>dt` | Terminate | Stop debugging session |
| `<leader>dl` | Run last | Repeat last debug configuration |

---

## 🐛 Troubleshooting

### Debugger Won't Start
**Problem:** `F5` does nothing or shows error

**Solution:**
1. Check test binary exists: `ls target/debug/deps/01-*`
2. Rebuild: `cargo build --tests`
3. Use full absolute path when prompted
4. Check `:DapShowLog` for errors

### Can't See Variables
**Problem:** Scopes panel is empty

**Cause:** Rust optimizations might strip debug info

**Solution:**
1. Ensure you used `cargo build --tests` (NOT `--release`)
2. Check `Cargo.toml` has debug symbols enabled:
```toml
[profile.dev]
debug = true
```

### Breakpoint Shows Gray Circle (○)
**Problem:** Breakpoint is rejected

**Cause:** Line has no executable code (comment, blank line, etc.)

**Solution:** Move breakpoint to a line with actual code

### Debug Adapters Not Installed
**Problem:** "codelldb not found" error

**Solution:**
1. Open `:Mason`
2. Search for `codelldb`
3. Press `i` to install
4. Wait for installation to complete
5. Restart Neovim

---

## 🎉 Next Steps

Now that you know the basics, try debugging:

1. **A complex loop:** Set breakpoint in `part_two` and step through the nested logic
2. **A failing test:** Debug `test_part_two_example_1` to understand the algorithm
3. **A function call chain:** Set breakpoint in `extract_amounts` and step through parsing

**Pro tips:**
- Use `F10` (step over) most of the time
- Use `F11` (step into) only when you want to see inside a function
- Use `F5` (continue) to skip boring parts
- Set multiple breakpoints and use `F5` to jump between interesting spots
- The REPL is your friend for testing hypotheses!

---

## 📚 Additional Resources

- Main cheatsheet: `~/.config/nvim/nvim-cheatsheet.md`
- Configuration: `~/.config/nvim/lua/plugins/dap.lua`
- DAP documentation: `:help dap`
- Rust debugging guide: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-codelldb

Happy debugging! 🎯
