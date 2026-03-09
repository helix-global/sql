using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(FileStreamOnDropIndexOption))]
    internal sealed class SqlScriptDomFileStreamOnDropIndexOption : SqlScriptDomIndexOption<FileStreamOnDropIndexOption>
        {
        #region ctor{IServiceProvider,FileStreamOnDropIndexOption}
        public SqlScriptDomFileStreamOnDropIndexOption(IServiceProvider context,FileStreamOnDropIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }