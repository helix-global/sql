using System.ComponentModel;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlEnumConverter<SqlIndexOptionType>))]
    public enum SqlIndexOptionType
        {
        Invalid,
        AllowPageLocks,
        AllowRowLocks,
        DataCompression,
        DropExisting,
        FillFactor,
        IgnoreDupKey,
        MaxDegreeOfParallelism,
        Online,
        PadIndex,
        SortedData,
        SortedDataReorg,
        StatisticsIncremental,
        SortInTempDb,
        StatisticsNoRecompute,
        StatisticsOnly,
        BucketCount,
        CompressionDelay,
        Resumable,
        MaxDuration,
        OptimizeForSequentialKey,
        WaitAtLowPriority,
        XmlCompression,
        LobCompaction,
        FileStreamOn,
        MoveTo,
        Order,
        CompressAllRowGroups,
        VectorMetric,
        VectorType,
        OptimizeForArraySearch
        }
    }