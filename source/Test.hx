package;

class Test {
    var name:String = "";
    public function new() {
        switch(Std.int(Math.random() * 5)) {
            case 0: name = "Mario";
            case 1: name = "Luigi";
            case 2: name = "Peach";
            case 3: name = "Yoshi";
            case 4: name = "Koopa";
        }
    }

    public function getName():String {
        return name;
    }
}