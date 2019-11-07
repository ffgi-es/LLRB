module RubyLLRB
  RED = true
  BLACK = false

  class LLRB
    attr_reader :root_node, :size

    def initialize
      @size = 0
    end

    def insert(key, value)
      @root_node = node_insert(@root_node, key, value)
      @root_node.colour = BLACK
    end

    def search(key)
      x = @root_node
      until x.nil?
        case key <=> x.key
        when 0 then return x.value
        when -1 then x = x.left
        when 1 then x = x.right
        end
      end
      return nil
    end

    private
    def node_insert(node, key, value)
      if node.nil?
        @size += 1
        return Node.new(key,value)
      else
        case key <=> node.key
        when 0 then node.value = value
        when -1 then node.left = node_insert(node.left, key, value)
        when 1 then node.right = node_insert(node.right, key, value)
        end
        return node
      end
    end
  end

  class Node
    attr_accessor :colour, :key, :value, :left, :right

    def initialize(key, value)
      @key = key
      @value = value
      @colour = RED
    end
  end
end
