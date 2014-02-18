module ReorderUtils

  # Actually perform the ordering using calculated steps
  def perform_reorder_of(ordered_ids, current)
    steps = calculate_reorder_steps(ordered_ids, current)
    steps.inject([]) do |result, (source, idx)|
      target = current[idx]
      if source.id != target.id
        source.swap(target, false)
        from = current.index(source)
        current[from], current[idx] = current[idx], current[from]
        result << source
      end
      result
    end
  end

  # Calculate the least amount of swap steps to achieve the requested order
  def calculate_reorder_steps(ordered_ids, current)
    steps = []
    current.each_with_index do |source, idx|
      new_idx = ordered_ids.index(source.id.to_s)
      steps << [source, new_idx] if idx != new_idx
    end
    steps
  end


end
