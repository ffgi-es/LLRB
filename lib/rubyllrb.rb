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
      return false unless self.size == other.size
      return true if self.size == 0
      self.root_node.each { |k, v| return false unless other.search(k) == v }
      return true
    end

    def each &block
      root_node.each &block if root_node
    end

    def pop
      return nil if root_node.nil?
      @root_node, value = delete_max(@root_node)
      root_node.colour = BLACK
      @size -= 1
      return value
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
        return Node.new(key,value)
      else
        case key <=> node.key
        when 0 then node.value = value
        when -1 then node.left = node_insert(node.left, key, value)
        when 1 then node.right = node_insert(node.right, key, value)
        end

        return fix_balance node
      end
    end

    def node_delete node, key
      return [nil, nil] if node.nil?
      case comp = key <=> node.key
      when -1
        node = move_red_left(node) if !is_red(node.left) && !is_red(node.left.left)
        node.left, value = node_delete(node.left, key)
      when 1, 0
        node = rotate_right(node) if is_red node.left
        return [nil, node.value] if comp == 0 and node.right.nil?
        if comp == 0
          node.key, node.value = node_min(node.right)
          node.right, value = delete_min(node.right)
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

    def delete_max node
      node = rotate_right(node) if is_red node.left
      return [nil, node.value] if node.right.nil?
      node = move_red_right(node) if !is_red(node.right) && !is_red(node.right.left)
      node.right, value = delete_max(node.right)
      return [fix_balance(node), value]
    end

    def delete_min node
      return [nil, node.value] if node.left.nil?
      node = move_red_left(node) if !is_red(node.left) && !is_red(node.left.left)
      node.left, value = delete_min(node.left)
      return [fix_balance(node), value]
    end

    def fix_balance node
      node = rotate_left(node) if is_red(node.right) && !is_red(node.left)
      node = rotate_right(node) if is_red(node.left) && is_red(node.left.left)
      colour_flip(node) if is_red(node.left) && is_red(node.right)
      return node
    end

    def is_red node
      return node.colour if node
      return false
    end

    def move_red_right node
      colour_flip(node)
      if is_red node.left.left
        node = rotate_right(node)
        colour_flip(node)
      end
      return node
    end

    def move_red_left node
      colour_flip(node)
      if is_red(node.right.left)
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
      left.each &block if left
      yield(key, value)
      right.each &block if right
    end
  end
end
