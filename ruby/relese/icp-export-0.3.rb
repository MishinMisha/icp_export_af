require "csv"


# Путь к файлу Csv
pathToCsv = '/home/mick/project/icp-export/ruby/test_kit_rb/061222.csv'


def antiFreezeParserEkb(pathToCsv)
# Значения абсорбции для отбора измерений из csv
  absorption = ['Ag 328.068',
                'Al 308.215',
                'B 249.772',
                'Ba 233.527',
                'Ca 393.366',
                'Cr 267.716',
                'Cu 324.754',
                'Fe 238.204',
                'K 766.491',
                'Mg 279.553',
                'Mn 259.372',
                'Mo 202.032',
                'Na 589.592',
                'Ni 341.476',
                'P 213.547',
                'Pb 283.305',
                'Sb 206.834',
                'Si 251.611',
                'Sn 283.998',
                'Ti 308.804',
                'V 292.401',
                'Y 377.433',
                'Zn 213.857']
  # Csv[row[string[]]]
  dataFromCsv = CSV.parse(File.binread(pathToCsv), headers: true)
  # [[Номер пробы, Элемент, Концентрация]]
  selectedData = []
  # Счетчик строк в dataFromCsv. Нужен для перебора
  rowCounter = 0
  # Заменяет заменяет значение концентрации из образца 0.25 на 0.05
  def lowConcentrationPut(csv, mesurement, selectedData, rowCounter)
    indexSolution = (csv['Solution Label'].index mesurement[0]) + 60
    if csv['Solution Label'][indexSolution] == '^-Na'
      lowCon = (csv['Corr Con'].index mesurement[6]) + 60
      selectedData[rowCounter] = [mesurement[0],
                                  mesurement[2],
                                  csv['Corr Con'][lowCon]]
      rowCounter += 1
    end
  end
  # Отбирает Номер пробы, Элемент, Концентрацию из dataFromCsv
  # Исключает измерения стандартов из отбора
  dataFromCsv.each do |mesurement|
    for element in absorption
      if element == mesurement[2]
        if mesurement[0] == '444'
          nil
        elsif mesurement[0] == '444_Na'
          nil
        elsif mesurement[0] == 'h20'
          nil
        elsif mesurement[0] == 'NaCl'
          nil
        elsif mesurement[2] == 'Na 589.592' and mesurement[6].to_i > 2000
          lowConcentrationPut(dataFromCsv, mesurement, selectedData, rowCounter)
        elsif mesurement[2] == 'K 766.491' and mesurement[6].to_i > 2000
          lowConcentrationPut(dataFromCsv, mesurement, selectedData, rowCounter)
        elsif mesurement[2] == 'Zn 213.857' and mesurement[6].to_i < 100
          lowConcentrationPut(dataFromCsv, mesurement, selectedData, rowCounter)
        elsif mesurement[0] == '^-Na'
          nil
        else
          selectedData[rowCounter] = [mesurement[0],
                                      mesurement[2],
                                      mesurement[6]]
          rowCounter += 1
        end
      end
    end
  end
  # Округление значений
  selectedData.each do |element|
    element[2] = element[2].to_f
    if element[1] == 'B 249.772'
      if element[2] < 1000
        element[2] = element[2] < 0 ? 0 : element[2].round
      else
        element[2] = element[2] < 0 ? 0 : element[2].round(-1)
      end
    elsif element[1] == 'P 213.547'
        if element[2] > 1000
          element[2] = element[2] < 0 ? 0 : element[2].round(-2)
        elsif element[2] < 100
          element[2] = element[2] < 0 ? 0 : element[2].round
        else
          element[2] = element[2] < 0 ? 0 : element[2].round(-1)
        end
    elsif element[1] == 'Mo 202.032'
      if element[2] > 100
        element[2] = element[2] < 0 ? 0 : element[2].round(-1)
      else
        element[2] = element[2] < 0 ? 0 : element[2].round
      end
    elsif element[1] == 'Si 251.611'
      if element[2] > 100
        element[2] = element[2] < 0 ? 0 : element[2].round(-1)
      else
        element[2] = element[2] < 0 ? 0 : element[2].round
      end
    elsif element[1] == 'Sb 206.834'
      if element[2] < 1
        element[2] = 0
      else
        element[2] = element[2] < 0 ? 0 : element[2].round
      end
    else
      element[2] = element[2] < 0 ? 0 : element[2].round
    end
  end
  return selectedData
end


antiFreezeParserEkb(pathToCsv).each do |array|
  puts print array
end
