classdef priorityFront
    
    properties (GetAccess = private)
        treeMap;
    end
    
    methods
        
        function obj = priorityFront()
            obj.treeMap = java.util.TreeMap;
        end
        function add(obj, key, value)
            if ~obj.treeMap.containsKey(key)
                obj.treeMap.put(key, java.util.ArrayList);
            end
            obj.treeMap.get(key).add(value);
        end
        
        function smallest = smallest(obj)
            if obj.treeMap.isEmpty
                smallest = [];
            else
                smallestKey = obj.treeMap.firstKey;
                list = obj.treeMap.get(smallestKey);
                if ~list.isEmpty
                   smallest = list.remove(list.size-1); 
                   if list.isEmpty
                       obj.treeMap.remove(smallestKey);
                   end
                else
                    smallest = [];
                end
            end
        end
        
        function ise = isEmpty(obj)
            if obj.treeMap.isEmpty
                ise = 1;
            else
                ise = 0;
            end
        end
    end
end