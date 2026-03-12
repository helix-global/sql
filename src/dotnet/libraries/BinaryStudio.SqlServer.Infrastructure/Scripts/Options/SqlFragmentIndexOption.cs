using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentIndexOption<T> : SqlFragmentObject<T>,ISqlScriptIndexOption
        where T: IndexOption
        {
        [UsedImplicitly][Field] public IndexOptionKind OptionKind { get; }
        public String Phrase { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            switch (OptionKind) {
                case IndexOptionKind.PadIndex:                 { Phrase = "PAD_INDEX";                   } break;
                case IndexOptionKind.FillFactor:               { Phrase = "FILLFACTOR";                  } break;
                case IndexOptionKind.SortInTempDB:             { Phrase = "SORT_IN_TEMPDB";              } break;
                case IndexOptionKind.IgnoreDupKey:             { Phrase = "IGNORE_DUP_KEY";              } break;
                case IndexOptionKind.StatisticsNoRecompute:    { Phrase = "STATISTICS_NORECOMPUTE";      } break;
                case IndexOptionKind.DropExisting:             { Phrase = "DROP_EXISTING";               } break;
                case IndexOptionKind.Online:                   { Phrase = "ONLINE";                      } break;
                case IndexOptionKind.AllowRowLocks:            { Phrase = "ALLOW_ROW_LOCKS";             } break;
                case IndexOptionKind.AllowPageLocks:           { Phrase = "ALLOW_PAGE_LOCKS";            } break;
                case IndexOptionKind.MaxDop:                   { Phrase = "MAXDOP";                      } break;
                case IndexOptionKind.DataCompression:          { Phrase = "DATA_COMPRESSION";            } break;
                case IndexOptionKind.BucketCount:              { Phrase = "BUCKET_COUNT";                } break;
                case IndexOptionKind.CompressionDelay:         { Phrase = "COMPRESSION_DELAY";           } break;
                case IndexOptionKind.Resumable:                { Phrase = "RESUMABLE";                   } break;
                case IndexOptionKind.MaxDuration:              { Phrase = "MAX_DURATION";                } break;
                case IndexOptionKind.OptimizeForSequentialKey: { Phrase = "OPTIMIZE_FOR_SEQUENTIAL_KEY"; } break;
                case IndexOptionKind.WaitAtLowPriority:        { Phrase = "WAIT_AT_LOW_PRIORITY";        } break;
                case IndexOptionKind.XmlCompression:           { Phrase = "XML_COMPRESSION";             } break;
                case IndexOptionKind.StatisticsIncremental:    { Phrase = "STATISTICS_INCREMENTAL";      } break;
                case IndexOptionKind.LobCompaction:            { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.FileStreamOn:             { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.MoveTo:                   { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.Order:                    { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.CompressAllRowGroups:     { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.VectorMetric:             { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.VectorType:               { Phrase = OptionKind.ToString(); } break;
                case IndexOptionKind.OptimizeForArraySearch:   { Phrase = OptionKind.ToString(); } break;
                }
            }
        #endregion
        }
    }