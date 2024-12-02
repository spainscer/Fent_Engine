package funkster.backend.util;

import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class CoolUtil
{
    public static function coolTextFile(path:String):Array<String>
    {
         var daList:Array<String> = OpenFlAssets.getText(path).trim().split('\n');
    
         for (i in 0...daList.length)
            daList[i] = daList[i].trim();
    
        return daList;
    }
    
    public static function coolStringFile(path:String):Array<String>
    {
        var daList:Array<String> = path.trim().split('\n');
    
        for (i in 0...daList.length)
            daList[i] = daList[i].trim();
    
        return daList;
    }
    
    public static function numberArray(max:Int, ?min = 0):Array<Int>
    {
        var dumbArray:Array<Int> = [];
            for (i in min...max)
                dumbArray.push(i);
            
        return dumbArray;
    }
}