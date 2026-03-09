using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlPadIndexOption))]
    internal sealed class SqlScriptPadIndexOption : SqlScriptOnOffIndexOption<SqlPadIndexOption>
        {
        #region ctor{IServiceProvider,SqlPadIndexOption}
        public SqlScriptPadIndexOption(IServiceProvider context,SqlPadIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }