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

    def == other
      return false unless other.is_a? LLRB
      return false unless size == other.size
      return true if size.zero?

      root_node.each { |k, v| return false unless other.search(k) == v }
      return true
    end

    def each &block
      root_node&.each(&block)
    end

    def max
      return node_max root_node unless root_node.nil?
    end

    def pop
      return nil if root_node.nil?

      @root_node, value = delete_max(@root_node)
      root_node.colour = BLACK
      @size -= 1
      return value
    end

    def min
      return node_min root_node unless root_node.nil?
    end

    def shift
      return nil if root_node.nil?

      @root_node, value = delete_min(@root_node)
      root_node.colour = BLACK
      @size -= 1
      return value
    end

    def delete key
      return nil if root_node.nil?

      @root_node, value = node_delete(root_node, key)
      root_node.colour = BLACK
      @size -= 1 unless value.nil?
      return value
    end

    private
    def node_insert(node, key, value)
      if node.nil?
        @size += 1
        return Node.new(key, value)
      end

      insert_below(node, key, value)
    end

    def insert_below(node, key, value)
      case key <=> node.key
      when 0 then node.value = value
      when -1 then node.left = node_insert(node.left, key, value)
      when 1 then node.right = node_insert(node.right, key, value)
      end

      fix_balance node
    end

    def node_delete node, key
      return [nil, nil] if node.nil?

      if (key <=> node.key).negative?
        node = move_red_left(node) if !red?(node.left) && !red?(node.left.left)
        node.left, value = node_delete(node.left, key)
      else
        node = rotate_right(node) if red? node.left
        return [nil, node.value] if (key <=> node.key).zero? && node.right.nil?

        node = move_red_right(node) if !red?(node.right) && 
          !node.right.nil? && !red?(node.right.left)

        if (key <=> node.key).zero?
          value = node.value
          node.key, node.value = node_min(node.right)
          node.right, _ = delete_min(node.right)
        else
          node.right, value = node_delete(node.right, key)
        end
      end

      return [fix_balance(node), value]
    end

    def node_min(node)
      return [node.key, node.value] if node.left.nil?

      return node_min(node.left)
    end

    def node_max node
      return [node.key, node.value] if node.right.nil?

      return node_max(node.right)
    end

    def delete_max node
      node = rotate_right(node) if red? node.left
      return [nil, [node.key, node.value]] if node.right.nil?

      node = move_red_right(node) if !red?(node.right) && !red?(node.right.left)
      node.right, value = delete_max(node.right)
      return [fix_balance(node), value]
    end

    def delete_min node
      return [nil, [node.key, node.value]] if node.left.nil?

      node = move_red_left(node) if !red?(node.left) && !red?(node.left.left)
      node.left, value = delete_min(node.left)
      return [fix_balance(node), value]
    end

    def fix_balance node
      node = rotate_left(node) if red?(node.right) && !red?(node.left)
      node = rotate_right(node) if red?(node.left) && red?(node.left.left)
      colour_flip(node) if red?(node.left) && red?(node.right)
      return node
    end

    def red? node
      return node.colour if node

      return false
    end

    def move_red_right node
      colour_flip(node)
      if red? node.left.left
        node = rotate_right(node)
        colour_flip(node)
      end
      return node
    end

    def move_red_left node
      colour_flip(node)
      if red?(node.right.left)
        node.right = rotate_right(node.right)
        node = rotate_left(node)
        colour_flip(node)
      end
      return node
    end

    def colour_flip node
      node.colour = !node.colour
      node.left.colour = !node.left.colour if node.left
      node.right.colour = !node.right.colour if node.right
    end

    def rotate_left(node)
      tmp = node.right
      node.right = tmp.left
      tmp.left = node
      tmp.colour = node.colour
      node.colour = RED
      return tmp
    end

    def rotate_right(node)
      tmp = node.left
      node.left = tmp.right
      tmp.right = node
      tmp.colour = node.colour
      node.colour = RED
      return tmp
    end
  end

  class Node
    attr_accessor :colour, :key, :value, :left, :right

    def initialize(key, value)
      @key = key
      @value = value
      @colour = RED
    end

    def each &block
      left&.each(&block)
      yield(key, value)
      right&.each(&block)
    end
  end
end
