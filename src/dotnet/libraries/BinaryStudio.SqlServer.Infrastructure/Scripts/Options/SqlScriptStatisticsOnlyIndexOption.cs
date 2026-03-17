using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlStatisticsOnlyIndexOption))]
    internal sealed class SqlScriptStatisticsOnlyIndexOption : SqlScriptOnOffIndexOption<SqlStatisticsOnlyIndexOption>
        {
        [UsedImplicitly][Field] public Int32 Value { get; }
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.StatisticsOnly; }}

        #region ctor{IServiceProvider,SqlStatisticsOnlyIndexOption}
        public SqlScriptStatisticsOnlyIndexOption(IServiceProvider context,SqlStatisticsOnlyIndexOption source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()} = {OnOffValue.ToString().ToLowerInvariant()}";
            }
        #endregion
        }
    }