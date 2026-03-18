using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentIndexOption<T> : SqlFragmentObject<T>,ISqlIndexOption
        where T: IndexOption
        {
        public SqlIndexOptionType Type { get; }
        public String Phrase { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            switch (source.OptionKind) {
                case IndexOptionKind.PadIndex:                 { Type = SqlIndexOptionType.PadIndex;                 Phrase = "PAD_INDEX";                   } break;
                case IndexOptionKind.FillFactor:               { Type = SqlIndexOptionType.FillFactor;               Phrase = "FILLFACTOR";                  } break;
                case IndexOptionKind.SortInTempDB:             { Type = SqlIndexOptionType.SortInTempDb;             Phrase = "SORT_IN_TEMPDB";              } break;
                case IndexOptionKind.IgnoreDupKey:             { Type = SqlIndexOptionType.IgnoreDupKey;             Phrase = "IGNORE_DUP_KEY";              } break;
                case IndexOptionKind.StatisticsNoRecompute:    { Type = SqlIndexOptionType.StatisticsNoRecompute;    Phrase = "STATISTICS_NORECOMPUTE";      } break;
                case IndexOptionKind.DropExisting:             { Type = SqlIndexOptionType.DropExisting;             Phrase = "DROP_EXISTING";               } break;
                case IndexOptionKind.Online:                   { Type = SqlIndexOptionType.Online;                   Phrase = "ONLINE";                      } break;
                case IndexOptionKind.AllowRowLocks:            { Type = SqlIndexOptionType.AllowRowLocks;            Phrase = "ALLOW_ROW_LOCKS";             } break;
                case IndexOptionKind.AllowPageLocks:           { Type = SqlIndexOptionType.AllowPageLocks;           Phrase = "ALLOW_PAGE_LOCKS";            } break;
                case IndexOptionKind.MaxDop:                   { Type = SqlIndexOptionType.MaxDegreeOfParallelism;   Phrase = "MAXDOP";                      } break;
                case IndexOptionKind.DataCompression:          { Type = SqlIndexOptionType.DataCompression;          Phrase = "DATA_COMPRESSION";            } break;
                case IndexOptionKind.BucketCount:              { Type = SqlIndexOptionType.BucketCount;              Phrase = "BUCKET_COUNT";                } break;
                case IndexOptionKind.CompressionDelay:         { Type = SqlIndexOptionType.CompressionDelay;         Phrase = "COMPRESSION_DELAY";           } break;
                case IndexOptionKind.Resumable:                { Type = SqlIndexOptionType.Resumable;                Phrase = "RESUMABLE";                   } break;
                case IndexOptionKind.MaxDuration:              { Type = SqlIndexOptionType.MaxDuration;              Phrase = "MAX_DURATION";                } break;
                case IndexOptionKind.OptimizeForSequentialKey: { Type = SqlIndexOptionType.OptimizeForSequentialKey; Phrase = "OPTIMIZE_FOR_SEQUENTIAL_KEY"; } break;
                case IndexOptionKind.WaitAtLowPriority:        { Type = SqlIndexOptionType.WaitAtLowPriority;        Phrase = "WAIT_AT_LOW_PRIORITY";        } break;
                case IndexOptionKind.XmlCompression:           { Type = SqlIndexOptionType.XmlCompression;           Phrase = "XML_COMPRESSION";             } break;
                case IndexOptionKind.StatisticsIncremental:    { Type = SqlIndexOptionType.StatisticsIncremental;    Phrase = "STATISTICS_INCREMENTAL";      } break;
                case IndexOptionKind.LobCompaction:            { Type = SqlIndexOptionType.LobCompaction;            Phrase = Type.ToString(); } break;
                case IndexOptionKind.FileStreamOn:             { Type = SqlIndexOptionType.FileStreamOn;             Phrase = Type.ToString(); } break;
                case IndexOptionKind.MoveTo:                   { Type = SqlIndexOptionType.MoveTo;                   Phrase = Type.ToString(); } break;
                case IndexOptionKind.Order:                    { Type = SqlIndexOptionType.Order;                    Phrase = Type.ToString(); } break;
                case IndexOptionKind.CompressAllRowGroups:     { Type = SqlIndexOptionType.CompressAllRowGroups;     Phrase = Type.ToString(); } break;
                case IndexOptionKind.VectorMetric:             { Type = SqlIndexOptionType.VectorMetric;             Phrase = Type.ToString(); } break;
                case IndexOptionKind.VectorType:               { Type = SqlIndexOptionType.VectorType;               Phrase = Type.ToString(); } break;
                case IndexOptionKind.OptimizeForArraySearch:   { Type = SqlIndexOptionType.OptimizeForArraySearch;   Phrase = Type.ToString(); } break;
                }
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()}";
            }
        #endregion
        #region M:FormatInline(ISqlObjectFormatter<ISqlIndexOption>):String
        public virtual String FormatInline(ISqlObjectFormatter<ISqlIndexOption> formatter)
            {
            formatter.WriteTo(Context,this,out var r);
            return r;
            }
        #endregion
        }
    }