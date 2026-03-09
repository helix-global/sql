using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlIgnoreDupKeyIndexOption))]
    internal sealed class SqlScriptIgnoreDupKeyIndexOption : SqlScriptOnOffIndexOption<SqlIgnoreDupKeyIndexOption>
        {
        #region ctor{IServiceProvider,SqlIgnoreDupKeyIndexOption}
        public SqlScriptIgnoreDupKeyIndexOption(IServiceProvider context,SqlIgnoreDupKeyIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }