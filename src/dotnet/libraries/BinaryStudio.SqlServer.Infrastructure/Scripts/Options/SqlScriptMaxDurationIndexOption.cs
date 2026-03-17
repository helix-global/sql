using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlMaxDurationIndexOption))]
    internal sealed class SqlScriptMaxDurationIndexOption : SqlScriptIndexOption<SqlMaxDurationIndexOption>
        {
        [UsedImplicitly][Field] public Int32 MaxDuration { get; }
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.MaxDuration; }}

        #region ctor{IServiceProvider,SqlMaxDurationIndexOption}
        public SqlScriptMaxDurationIndexOption(IServiceProvider context,SqlMaxDurationIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }