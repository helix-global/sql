using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlMissingInsertSource))]
    internal sealed class SqlScriptMissingInsertSource : SqlScriptInsertSource<SqlMissingInsertSource>
        {
        #region ctor{IServiceProvider,SqlMissingInsertSource}
        public SqlScriptMissingInsertSource(IServiceProvider context,SqlMissingInsertSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }