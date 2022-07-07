public class DateUtils {
    public static String toDayAndMonth(Date input){
        String result = DateTime.newInstance(input.year(), input.month(), input.day()).format('dd-MMM');

        return result.replaceAll('-', ' ');
    }
}