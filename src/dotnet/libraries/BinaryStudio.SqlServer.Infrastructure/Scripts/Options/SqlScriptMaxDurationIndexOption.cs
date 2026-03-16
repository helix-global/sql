using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlMaxDurationIndexOption))]
    internal sealed class SqlScriptMaxDurationIndexOption : SqlScriptIndexOption<SqlMaxDurationIndexOption>
        {
        public Int32 MaxDuration {get{ return Source.MaxDuration; }}

        #region ctor{IServiceProvider,SqlMaxDurationIndexOption}
        public SqlScriptMaxDurationIndexOption(IServiceProvider context,SqlMaxDurationIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }