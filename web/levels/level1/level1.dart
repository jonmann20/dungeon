part of dungeon;

class Level_1 {
	GameObj wise;
	Enemy fish;
	Dialog dialog;
	bool underground, transitionOver;
  
	String instr;
  
	Level_1(){
    	dialog = new Dialog();
    	wise = new GameObj(HALFW, HALFH - 35, 30, 43, "wiseMan.png");
    	fish = new Enemy(5, "fishCard.png", "Fish", HALFW, 90, 71, 40, "fish.png");
    
    	underground = transitionOver = false;
    	p.movLocked = true;
	}
  
	void Update(){
		if(level.isCutscene){
	    	updateCutscene();
	    }
	    else if(fish.captured){
	    
	    }
	    else if(!underground){
	    	if(util.checkCollision(p, stairs, 12)){
	        	underground = true;
	        	canvasTransition();
	      	}
	    }
	    else if(underground){
	    	if(fish.health > 0){
	        	if(util.checkCollision(p, fish, 3)){
	          		if(!p.invincible){
	            		p.hit();
	          		}
	        	}
	      	}
	      	else {// fish is dead
	     		if(key.lastKeyUp == KeyCode.SHIFT){
	        		key.resetKeys();
	            	fish.captured = true;
	        	}
	      	}
	      
	      	fish.update();
	    }    
	}
  
  void updateCutscene(){
    if(key.lastKeyDown == KeyCode.ENTER){
       if(dialog.dialogLine < dialog.dialog.length - 1)
         ++dialog.dialogLine;
       else
         p.movLocked = false;
       
       if(p.dir == Direction.PICKED){
         p.vX = p.vY = 0;
         p.movLocked = level.isCutscene = false;
         p.dir = Direction.UP;
       }
       
       key.resetKeys();
    }
    
    if(!p.device.usable && !p.movLocked && util.checkCollision(p, p.device)){
      p.device.usable = p.sword.usable = p.movLocked = true;
      p.dir = Direction.PICKED;
    }
  }
  
	/**************** Render ****************/
	void Render(){
    	level.drawBg();
    
		if(level.isCutscene){
			drawCutscene();
		}
		else {
			if(!transitionOver){
		    	stairs.drawD(FULLW - 60, 70);
		  	}
		  	else {// underground
				if(util.flashTxt(11, "FIGHT")){ // done flashing text; TODO: hide item's during text flash
		      		p.movLocked = false;
		      		drawUnderground();
		    	}
		  	}// end underground 
		}// end !isCutscene
	}
  
	void OnGUI(){
		if(instr != null){
			ctx.font = "8px 'Press Start 2P'";
			ctx.fillStyle = "#ccc";
			ctx.fillText(instr, 10, FULLH - 10);
		}
	}
  
	void drawUnderground(){
		if(!fish.captured){
			fish.draw();
			fish.drawHealth();
      
			if(fish.health > 0){
				instr = "USE SPACEBAR";
				fish.animate = true;
	      	}
	      	else{
	        	instr = "USE SHIFT";
	        	fish.animate = false;
	      	}
    	}
    	else if(fish.health <= 0){  
      		if(fish.captured){
        		fish.drawCard();
    
	        	p.health = p.maxHealth;
    		}
    	}
	}
  
  void canvasTransition(){
    p.movLocked = true;
    p.vX = p.vY = 0;
    canvas.classes.remove("preTransition");
    canvas.classes.add("duringTransition");
    
    canvasListener = canvas.onTransitionEnd.listen((e){
      level.bgColor[1] = '#5e2605';
      p.x = HALFW - p.w/2;
      p.y = FULLH - p.h - 20;
      
      canvas.classes.remove("duringTransition");
      canvas.classes.add("preTransition");
      
      p.dir = Direction.UP;
      transitionOver = true;
    });
  }
  
  void drawCutscene(){
    if(!p.device.usable)
      drawWiseMan();  
    
    // draw dialog/device
    if(p.movLocked){ 
      if(!p.device.usable)
        util.blinkTxt(10, wise.x + 160, wise.y + 25);
      else{
        p.device.drawD(p.x+p.w/2-p.device.w/2, p.y-p.device.h-4, p.device.imgU);
        util.blinkTxt(10, p.x + 160, p.y + 25);
      }
    }
    else if(!p.device.usable){
      p.device.draw(p.device.imgU);
    }
  }
  
  void drawWiseMan(){
    wise.draw();
    
    // display text
    ctx.font = "11px 'Press Start 2P'";
    dialog.dialogW = ctx.measureText(dialog.dialog[dialog.dialogLine]).width;
    
    ctx.fillStyle = "#000";                                                   // dialog box
    ctx.fillRect(wise.x + 24, wise.y - 48, dialog.dialogW + 7, 42);
    ctx.fillStyle = "#e1e1e1";
    ctx.fillRect(wise.x + 20, wise.y - 53.5, dialog.dialogW + 7, 42);
    
    ctx.fillStyle = "#000";                                                   // dialog
    ctx.fillText(dialog.dialog[dialog.dialogLine], wise.x + 24, wise.y - 25);
  }
}

