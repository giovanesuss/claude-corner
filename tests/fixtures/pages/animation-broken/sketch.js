// TEST: .js entry that throws on purpose — exercises wrapAnimation()'s try/catch
// error overlay (regression test for the "blank canvas" class of bugs: a script
// error used to fail silently with nothing rendered and no feedback).

ctx.fillStyle = '#191714';
ctx.fillRect(0, 0, canvas.width, canvas.height);

thisFunctionDoesNotExist();
