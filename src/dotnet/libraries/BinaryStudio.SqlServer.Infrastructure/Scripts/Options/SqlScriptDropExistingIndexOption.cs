using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropExistingIndexOption))]
    internal sealed class SqlScriptDropExistingIndexOption : SqlScriptIndexOption<SqlDropExistingIndexOption>
        {
        #region ctor{IServiceProvider,SqlDropExistingIndexOption}
        public SqlScriptDropExistingIndexOption(IServiceProvider context,SqlDropExistingIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }